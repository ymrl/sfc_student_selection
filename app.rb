#coding:UTF-8
require 'sinatra'
require 'haml'
require 'cgi'
require './model.rb'



configure do
  set :haml, :format => :html5
end
helpers do
  def h(s)
    CGI.escapeHTML s
  end
end

get '/' do
  haml :index
end
get '/js.js' do
  coffee :js
end
get '/hot' do
  @hots = LectureModel.limit(40).filter(:selection=>true,:finished=>false).filter('odds > 1.0').order(:odds).reverse.all
  haml :hot
end

get '/:num' do
  num = params[:num].to_s
  @num = num
  if num !~ /^\d{8}$/
    @pms = []
  else
    @pms = PermissionModel.filter(:number=>num).all
  end
  @intern = request.ip.match(/^133\.27\./)
  haml :list
end


