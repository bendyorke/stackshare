require_relative './assert.rb'
require 'open-uri'
require 'json'

class Api
  BASE = 'https://api.stackshare.io/v1/'

  def initialize token
    @token = token
  end

  def tags page = 0
    url = tags_url page: page
    res = JSON.parse open(url).read
    unless res.empty?
      res << tags(page + 1)
    end
    res
  end

  def tags_url **params
    build_url '/stacks/tags', params
  end

  def stacks_url **params
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
