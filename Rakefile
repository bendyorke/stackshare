require 'dotenv/tasks'

task :start => :dotenv do
  %x{shotgun}
end

namespace :fetch do
  task :tags => :dotenv do
    require_relative 'api.rb'
    ENV['DEBUG'] = 'true' # for console printing
    api = Api.new(ENV["STACKSHARE_ACCESS_TOKEN"])
    tags = api.save_tags
  end
end
