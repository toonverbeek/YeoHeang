require 'rubygems'
require 'sinatra'
require 'instagram'

configure do
  enable :sessions
end

recent_media_url = "https://api.instagram.com/v1/users/271035399/media/recent/?client_id=2d53c155803e4fda8dfb34d1bcf8d4a4"
USER_ID=271035399

Instagram.configure do |config|
  config.client_id = "2d53c155803e4fda8dfb34d1bcf8d4a4"
  config.client_secret = "1d36c03c071e4da088afed8faf565524"
  # For secured endpoints only
  #config.client_ips = '<Comma separated list of IPs>'
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'stranger'
  end
  def media
    Instagram.user_recent_media(USER_ID)
  end
end

before '/secure/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry guacamole, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/picture-stream' do
  erb :picture_stream
end

get '/login/form' do 
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from 
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end


get '/secure/place' do
  erb "This is a secret place that only <%=session[:identity]%> has access to!"
end
