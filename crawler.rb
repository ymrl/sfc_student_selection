#coding:UTF-8
require './model.rb'
require 'pit'
require 'twitter'
require 'sfcsfs'

config = Pit.get("sfcsfs", :require => {
    :account  => "your CNS account",
    :password => "your CNS password"
})
Twitter.configure do |config|
   c= Pit.get("student_selection_twitter_api",:require => {
    :consumer_key        => "Consumer Key",
    :consumer_secret     => "Consumer Secret",
    :access_token        => "Access Token",
    :access_token_secret => "Access Token Secret"
  })
  config.consumer_key       = c[:consumer_key       ]
  config.consumer_secret    = c[:consumer_secret    ]
  config.oauth_token        = c[:access_token       ]
  config.oauth_token_secret = c[:access_token_secret]
end
client = Twitter::Client.new
agent = nil
tried = false
begin
  agent = SFCSFS.login(config[:account],config[:password])
rescue
  if !tried
    puts "retry..."
    sleep 10
    tried = true
    retry
  else
    exit 1
  end
end

lecture_models = Lecture.filter(:finished=>false).find
lectures = nil
if lecture_models.to_a.length > 0
  lectures = lecture_models.map{|e| SFCSFS::Lecture.new(agent,e.title,e.instructor,:yc=>e.yc,:ks=>e.ks,:place=>e.place)}
else
  lectures = agent.my_schedule
end

lectures.each do |lecture|
  serial = lecture.yc
  next if !lecture.yc


  lecture_model = Lecture.find(:yc => lecture.yc)
  next if lecture_model && (lecture_model.finished || !lecture_model.selection)
   
  # 履修選抜リストがvu8だと真っ白になる問題への対応
  # TODO: もうちょっとスマートにしたい
  default_uri = agent.base_uri
  agent.base_uri = URI.parse('https://vu9.sfc.keio.ac.jp/')

  tried = false
  begin
    lecture.get_detail
  rescue
    if !tried
      puts "retry..."
      sleep 10
      tried = true
      retry
    else
      agent.base_uri = default_uri
      next
    end
  ensure
    agent.base_uri = default_uri
  end


  page = agent.doc.to_s

  #selection = !page.match(/《履修人数を制限しない》/)
  selection = lecture.limit
  list_link = page.match(/履修許可者確認/)
  no_selection = page.match(/「履修者選抜なし」となりました/)
  finished = !selection || list_link || no_selection

  puts "#{lecture.title} : #{lecture.title} (#{lecture.instructor} / Selection:#{selection ? 'Yes' : 'No'} / Finished:#{finished ? 'Yes' : 'No'} / Applicants:#{lecture.applicants}  / Limit:#{lecture.limit})"

  if !lecture_model
    lecture_model = Lecture.create(:yc => lecture.yc,
                   :ks => lecture.ks,
                   :title  => lecture.title,
                   :selection => (selection ? true : false),
                   :finished  => (finished ? true: false),
                   :applicants => lecture.applicants,
                   :limit      => lecture.limit,
                   :odds       => lecture.limit && lecture.limit != 0 ? lecture.applicants.to_f / lecture.limit.to_f : 0,
                   :instructor => lecture.instructor,
                   :place => lecture.place,
    )
  else
    lecture_model.update( :finished   => (finished ? true: false),
                          :applicants => lecture.applicants,
                          :limit      => lecture.limit,
                          :odds       => lecture.limit && lecture.limit != 0 ? lecture.applicants.to_f / lecture.limit.to_f : 0,
                          :instructor => lecture.instructor,
                          :place      => lecture.place )
  end

  permissions = []
  tweet = nil

  if list_link

      # 履修選抜リストがvu8だと真っ白になる問題への対応
      # TODO: もうちょっとスマートにしたい
    default_uri = agent.base_uri
    agent.base_uri = URI.parse('https://vu9.sfc.keio.ac.jp/')

    list = nil
    tried = false
    begin
      list = lecture.student_selection_list
    rescue
      if !tried
        puts "retry..."
        sleep 10
        tried = true
        retry
      else
        agent.base_uri = default_uri
        next
      end
    ensure
      agent.base_uri = default_uri
    end

    list.each do |n|
      next if n !~ /^\d{8}/
      permissions.push(Permission.create(
          :number => n,
          :lecture_id => lecture_model.id
      ))
    end
    if permissions.length > 0
      tweet = "#{lecture.title} (#{lecture.instructor}君) の履修選抜結果が出ました。#{permissions.length}人に履修許可が出ています"
    else
      finished = false
      lecture_model.update( :finished   => false)
    end
  elsif no_selection
    tweet = "#{lecture.title} (#{lecture.instructor}君) は「履修選抜なし」になった模様です"
  end

  if tweet
    tweet += " #SFC履修選抜 http://履修選抜.死ぬ.jp/"
    puts tweet
    begin
      client.update tweet
    rescue=>e
      p e
      warn e
    end
  end
end
