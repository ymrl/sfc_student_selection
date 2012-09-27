# coding:UTF-8
require 'pit'
require 'sfcsfs'

## addall.rb
# 
# 今学期開講されるすべての科目を履修希望登録します。
# see also : https://github.com/ymrl/sfcsfs/blob/master/tasks/add.rake
# 

config = Pit.get("sfcsfs", :require => {
    :account  => "your CNS account",
    :password => "your CNS password"
})
agent = SFCSFS.login(config[:account],config[:password])
list = agent.all_classes_of_this_semester
list.each do |lecture|
  puts "#{lecture.title} (#{lecture.instructor})"
  retry_count = 0
  begin
    lecture.add_to_plan
  rescue
    sleep 60
    retry_count += 1
    if retry_count < 10
      retry
    end
  end
end
