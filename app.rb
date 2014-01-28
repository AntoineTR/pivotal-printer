require 'sinatra'
require 'pivotal-tracker'
require 'securerandom'
require './pdf'

enable :sessions
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
  session[:apikey] = params[:apikey]
  PivotalTracker::Client.token = session[:apikey]
  @projects = PivotalTracker::Project.all
  erb :projects, :locals => { :projects => @projects }
end

post '/print_label' do
  pid = params[:id]
  lid = params[:label_id]
  PivotalTracker::Client.token = session[:apikey]
  @project = PivotalTracker::Project.find(pid.to_i)
  logger.info(@project.inspect)
  @stories = @project.stories.all(:filter => 'label:"'+lid+'"')
  logger.info(@stories.inspect)
  filename = 'pivotal_cards_'+SecureRandom.hex+'.pdf'
  #headers["Content-Type"] = "Application/octet-stream"
  headers["Content-Disposition"] = "attachment;filename=" + filename
  get_cards_file(@stories)
  #send_file get_cards_file(@stories), :filename => filename, :type => 'Application/octet-stream'
end

post '/print_iteration' do
  pid = params[:id]
  iid = params[:iteration_id]
  PivotalTracker::Client.token = session[:apikey]
  @project = PivotalTracker::Project.find(pid)
  
end