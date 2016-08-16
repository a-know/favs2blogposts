require 'sinatra'
require 'active_record'
require 'twitter'
require 'hatenablog'

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || "sqlite3:db/development.db")

class LatestFavsTweets < ActiveRecord::Base
end

get '/' do
end

get '/register' do
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  latest_fav = LatestFavsTweets.order(:created_at).all.first
  latest_fav ||= LatestFavsTweets.new

  favs = client.favorites("a_know")
  latest_fav = LatestFavsTweets.new
  latest_fav.status_id = favs.first.id
  latest_fav.save!
end

get '/post' do
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  latest_fav = LatestFavsTweets.order(:created_at).all.first

  if latest_fav.nil? || latest_fav.status_id.nil?
    favs = client.favorites("a_know")
    latest_fav = LatestFavsTweets.new
    latest_fav.status_id = favs.first.id
    latest_fav.save!
  else
    favs = client.favorites("a_know", since_id: latest_fav.status_id, count: 100)
    unless favs.empty?
      latest_fav.status_id = favs.first.id
      latest_fav.save!
    end
  end

  content = favs.empty? ? "この日の fav はありませんでした。" : ""
  favs.each do |fav|
    content += "[https://twitter.com/#{fav.user.screen_name}/status/#{fav.id}:embed]\n"
  end

  Hatenablog::Client.create do |blog|
    blog.post_entry((Time.now - 86400).strftime("%Y-%m-%d のfavs"), content, ['今日の favs'])
  end
end
