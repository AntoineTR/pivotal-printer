require 'sinatra'

set :sessions, true
set :views, Proc.new { File.join(root, "views") }
set :bind, '0.0.0.0'
set :port, 3000

error do
  erb :'500'
end

get '/' do
  erb :index
end

post '/' do
  params[:apikey] 
end