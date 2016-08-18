require 'sinatra'
require 'active_record'
require 'twitter'
require 'hatenablog'

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || "sqlite3:db/development.db")

class LatestFavsTweets < ActiveRecord::Base
end

def twitter_client
  @client ||= Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
end

def latest_fav
  @latest_fav ||= (LatestFavsTweets.order(:created_at).all.first || LatestFavsTweets.new)
end

def register_latest_fav
  favs = twitter_client.favorites(ENV['USER_SCREEN_NAME'], count: 1)
  latest_fav.status_id = favs.first.id
  latest_fav.save!
end

def yesterday
  old = ENV['TZ']
  utc = Time.now.dup.utc - 86400
  ENV['TZ'] = ENV['BLOG_TIMEZONE']
  output = utc.localtime
  ENV['TZ'] = old
  output
end

if latest_fav.nil? || latest_fav.status_id.nil?
  register_latest_fav
else
  favs = twitter_client.favorites(ENV['USER_SCREEN_NAME'], since_id: latest_fav.status_id, count: 100)
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
  blog.post_entry(yesterday.strftime("%Y-%m-%d のfavs"), content, ['今日の favs'])
end
