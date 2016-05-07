require 'dotenv/tasks'

task :start => :dotenv do
  %x{shotgun}
end

namespace :fetch do
  task :api => :dotenv do
    require_relative 'api.rb'
    ENV['DEBUG'] = 'true' # for console printing
    @api = Api.new(ENV["STACKSHARE_ACCESS_TOKEN"])
  end

  task :tags => :api do
    tags = @api.save_tags
  end

  task :layers => :api do
    tags = @api.save_layers
  end
end
