#coding:UTF-8
require './model.rb'
require 'pit'
require 'twitter'
require './lib/sfcsfs/lib/sfcsfs'

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

@agent = SFCSFS.login(config[:account],config[:password])
lectures = @agent.my_schedule

lectures.each do |l|
  serial = l.query['yc']
  next if !serial

  lecture_model = LectureModel.find(:serial => serial)
  next if lecture_model && (lecture_model.finished || !lecture_model.selection)

  @agent.get_lecture_detail(l)

  page_encoding = @agent.page.body.encoding
  encoded_page = @agent.page.body.force_encoding(@agent.page.encoding).encode(Encoding::UTF_8,:undef=>:replace,:invalid=>:replace)

  selection = !encoded_page.match(/《履修人数を制限しない》/)
  list_link = @agent.page.link_with(:text=>/履修許可者確認/)
  no_selection = encoded_page.match(/「履修者選抜なし」となりました/)
  finished = !selection || list_link || no_selection

  puts "#{serial} : #{l.title} (#{l.instructor} / Selection:#{selection ? 'Yes' : 'No'} / Finished:#{finished ? 'Yes' : 'No'} / Applicants:#{l.applicants}  / Limit:#{l.limit})"

  permissions = []
  tweet = nil

  if list_link
    list_link.click
    list = @agent.page.search('tr[bgcolor="#efefef"] td').map{|e| e.text}
    if list.length == 0
      m = @agent.page.uri.to_s.match(/vu(\d)/)
      if m
        n = (m=='9' ? 8 : 9)
        @agent.get @agent.page.uri.to_s.gsub(/vu\d/,"vu#{n}")
        list = @agent.page.search('tr[bgcolor="#efefef"] td').map{|e| e.text}
      end
    end
    list.each do |n|
      next if n !~ /^\d{8}/
      permissions.push(PermissionModel.create(
          :number => n,
          :lecture_serial => serial,
          :lecture_title => title
        ))
    end
    if permissions.length > 0
      tweet = "#{l.title} (#{l.instructor}君) の履修選抜結果が出ました。#{permissions.length}人に履修許可が出ています"
    else
      finished = false
    end
  end


  if lecture_model
    if no_selection
      tweet = "#{l.title} (#{l.instructor}君) は「履修選抜なし」になった模様です"
    end
    lecture_model.update( :finished   => (finished ? true: false),
                          :applicants => l.applicants,
                          :limit      => l.limit,
                          :odds       => l.limit ? l.applicants.to_f / l.limit.to_f : 0,
                          :instructor => l.instructor,
    )
  else
    LectureModel.create(:serial => serial,
                        :title  => l.title,
                        :selection => (selection ? true : false),
                        :finished  => (finished ? true: false),
                        :applicants => l.applicants,
                        :limit      => l.limit,
                        :odds       => l.limit ? l.applicants.to_f / l.limit.to_f : 0,
                        :instructor => l.instructor,
    )
  end
  if tweet
    tweet += " #SFC履修選抜 http://xn--8uqs71aoyeyq7c.xn--s9j219o.jp/"
    puts tweet
    begin
      client.update tweet
    rescue=>e
      p e
      warn e
    end
  end
end
