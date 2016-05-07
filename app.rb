require 'sinatra/base'
require 'json'
require 'haml'
require_relative 'api.rb'

class App < Sinatra::Base
  before do
    @api = Api.new(ENV['STACHSHARE_ACCESS_TOKEN'])
  end

  get '/' do
    @tags = @api.load_tags
    haml :index
  end

  post '/recommendations' do
    @tag = params[:tag]
    haml :recommendation
  end
end
