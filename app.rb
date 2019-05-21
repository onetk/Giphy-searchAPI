require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load


get '/' do
  erb :index
end


post '/search' do
  puts "Search keyword >> #{params[:keyword]}"

  def Giphy(text,limit=20)
    # テキスト情報をGiphyAPI検索 >> https://developers.giphy.com/docs/
    option = 'api_key='+ENV['GIPHY_API']+'&q='+URI.encode(text)+'&limit='+limit.to_s
    url = 'http://api.giphy.com/v1/gifs/search?'+option

    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body
    result = JSON.parse(buffer)
    return result
  end

  @keyword = params[:keyword]
  @gif_urls = []

  Giphy(params[:keyword])["data"].each do |item|
  @gif_urls.concat([item["images"]["fixed_height"]["url"]])
  end

  erb :index
end
