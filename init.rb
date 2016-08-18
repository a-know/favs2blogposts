require 'active_record'
require 'twitter'

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

favs = twitter_client.favorites(ENV['USER_SCREEN_NAME'], count: 1)
latest_fav.status_id = favs.first.id
latest_fav.save!
