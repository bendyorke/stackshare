require 'sinatra/base'
require 'json'
require 'haml'
require_relative 'api.rb'
require_relative 'rec_engine.rb'

class App < Sinatra::Base
  before do
    @api = Api.new(ENV['STACKSHARE_ACCESS_TOKEN'])
  end

  get '/' do
    @tags = @api.load_tags
    haml :index
  end

  post '/recommendations' do
    @tag = @api.load_tags.find { |t| t["id"].to_s == params[:tag] }
    @layers = RecEngine.recommend_for_tag(params[:tag]).select{ |l| l["recommendation"] }
    haml :recommendation
  end
end
