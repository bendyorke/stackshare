require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    "<h1>Hello World!</h1>"
  end

  get '/tags' do

  end
end
