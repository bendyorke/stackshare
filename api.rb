require_relative './assert.rb'
require 'open-uri'
require 'json'
require 'yaml'

class Api
  BASE = 'https://api.stackshare.io/v1/'

  def initialize token
    @token = token
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
    end
  end

  def load_layers
    path = ENV["LAYERS_PATH"]
    if File.file? path
      YAML.load(File.read(ENV["LAYERS_PATH"]))
    else
      []
    end
  end

  def save_layers
    layers = fetch_layers
    File.open(ENV["LAYERS_PATH"], 'w') { |f| f.write(YAML.dump(layers)) }
    layers
  end

  def fetch_tools layer_id, page = 0
    url = tools_url layer_id: layer_id, page: page
    res = JSON.parse open(url).read

    # When preloading tools, DEBUG will be set to true
    puts "Fetching tools for layer #{layer_id}, page #{page}..." if ENV['DEBUG']

    # No headers are set to indicate it is the last page,
    # so just assume that anything besides a 20 item array is the last page
    unless res.class != Array || res.length < 20
      res.concat fetch_tools(layer_id, page + 1)
    end

    res
  end

  def fetch_stacks tag_id
    url = stacks_url tag_id: tag_id
    res = JSON.parse open(url).read
  end

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
    res = JSON.parse open(url).read

    # Since the pages are limited to 20 tags, it's much more efficient
    # to prefetch them.  Fetch tasks will set DEBUG to true
    puts "Fetching page #{page}..." if ENV['DEBUG']

    # No headers are set to indicate it is the last page,
    # so just assume that anything besides a 20 item array is the last page
    unless res.class != Array || res.length < 20
      res.concat fetch_tags(page + 1)
    end

    res
  end

  def save_tags
    tags = fetch_tags
    File.open(ENV["TAGS_PATH"], 'w') { |f| f.write(YAML.dump(tags)) }
    tags
  end

  def layers_url
    build_url '/tools/layers'
  end

  def tools_url **params
    build_url '/tools/lookup', params
  end

  def tags_url **params
    build_url '/stacks/tags', params
  end

  def stacks_url **params
    build_url '/stacks/lookup', params
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
