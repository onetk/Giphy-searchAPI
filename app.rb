require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load


get '/' do
  @gif_urls = Gif.all
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
  # @gif_urls = []
  # @gif_urls = Gif.all


  Giphy(params[:keyword],1)["data"].each do |item|
  # @gif_urls.concat([item["images"]["fixed_height"]["url"]])

    if !Gif.exists?(:gif_id => CGI.escapeHTML(item["id"]) )

      import_y_m_d = (item["import_datetime"].split(" ")[0].split("-"))
      import_h_m_s = (item["import_datetime"].split(" ")[1].split(":"))
      import_array = import_y_m_d.concat(import_h_m_s).map!(&:to_i)
      import_time  = DateTime.new(import_array[0],import_array[1],import_array[2],import_array[3],import_array[4],import_array[5])

      trend_y_m_d = (item["trending_datetime"].split(" ")[0].split("-"))
      trend_h_m_s = (item["trending_datetime"].split(" ")[1].split(":"))
      trend_array = trend_y_m_d.concat(trend_h_m_s).map!(&:to_i)

      if trend_array[1]==0 || trend_array[2]==0
        Gif.create( gif_id: CGI.escapeHTML(item["id"]),
                    gif_url: item["images"]["fixed_height"]["url"],
                    upload_datetime: import_time )
      else
        trend_time  = DateTime.new(trend_array[0],trend_array[1],trend_array[2],trend_array[3],trend_array[4],trend_array[5])

        Gif.create( gif_id: CGI.escapeHTML(item["id"]),
                    gif_url: item["images"]["fixed_height"]["url"],
                    trend_datetime: trend_time,
                    upload_datetime: import_time )
      end
    end

  end
  @gif_urls = Gif.all
  # erb :index
  redirect '/'
end
