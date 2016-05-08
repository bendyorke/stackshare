require_relative './assert.rb'
require 'open-uri'
require 'json'
require 'yaml'

class Api
  BASE = 'https://api.stackshare.io/v1/'

  def initialize token = ''
    @token = token
  end

  ## LAYERS ####################################################################

  def load_layers
    path = ENV["LAYERS_PATH"]
    if File.file? path
      YAML.load(File.read(ENV["LAYERS_PATH"]))
    else
      []
    end
  end

  def fetch_layers
    url = layers_url
    res = JSON.parse open(url).read

    # When preloading layers, DEBUG will be set to true
    puts "Fetching layers..." if ENV['DEBUG']

    # The response is just the names and ids of the layers,
    # we need to get the contents of the layers
    res.map do |layer|
      layer['tools'] = fetch_tools(layer['id'])
      layer
    end
  end

  def save_layers
    layers = fetch_layers
    File.open(ENV["LAYERS_PATH"], 'w') { |f| f.write(YAML.dump(layers)) }
    layers
  end

  def layers_url
    build_url '/tools/layers'
  end

  ## TOOLS ######################################################################

  def fetch_tools layer_id, page = 0
    url = tools_url layer_id: layer_id, page: page
    begin
      # When preloading tools, DEBUG will be set to true
      print "Fetching tools for layer #{layer_id}, page #{page}..." if ENV['DEBUG']
      res = JSON.parse open(url).read
      print "[#{res.count}]\n" if ENV['DEBUG']
    rescue => e
      print "Fetched #{page} pages" if ENV['DEBUG']
    end

    # No headers are set to indicate it is the last page,
    # and pages contain variable amounts of entries.  Don't assume anything!
    if res
      res.concat fetch_tools(layer_id, page + 1)
    else
      []
    end
  end

  def tools_url **params
    build_url '/tools/lookup', params
  end

  ## STACKS ####################################################################

  def fetch_stacks tag_id
    url = stacks_url tag_id: tag_id
    res = JSON.parse open(url).read
  end

  def stacks_url **params
    build_url '/stacks/lookup', params
  end

  ## TAGS ######################################################################

  def load_tags
    path = ENV["TAGS_PATH"]
    if File.file? path
      YAML.load(File.read(ENV["TAGS_PATH"]))
    else
      []
    end
  end

  def fetch_tags page = 0
    url = tags_url page: page
    begin
      # When preloading tags, DEBUG will be set to true
      print "Fetching tags, page #{page}..." if ENV['DEBUG']
      res = JSON.parse open(url).read
      print "[#{res.count}]\n" if ENV['DEBUG']
    rescue => e
      print "Fetched #{page} pages" if ENV['DEBUG']
    end

    # No headers are set to indicate it is the last page,
    # and pages contain variable amounts of entries.  Don't assume anything!
    if res
      res.concat fetch_tags(layer_id, page + 1)
    else
      []
    end
  end

  def save_tags
    tags = fetch_tags
    File.open(ENV["TAGS_PATH"], 'w') { |f| f.write(YAML.dump(tags)) }
    tags
  end

  def tags_url **params
    build_url '/stacks/tags', params
  end

  private
  def build_url path, params = {}
    BASE + path.gsub(/(^\/|\/$)/, '') + build_params(params)
  end

  def build_params params
    with_auth = {access_token: @token}.merge(params)
    '?' + URI.encode_www_form(with_auth)
  end
end

if __FILE__ == $0
  api = Api.new('token')

  assert "builds the correct tags url without params" do
    api.tags_url == "https://api.stackshare.io/v1/stacks/tags?access_token=token"
  end

  assert "build the correct tags url with params" do
    api.tags_url(page: 2).end_with? "/v1/stacks/tags?access_token=token&page=2"
  end
end
