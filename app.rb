require 'sinatra'
require 'active_record'
require 'twitter'
require 'hatenablog'

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"] || "sqlite3:db/development.db")

class LatestFavsTweets < ActiveRecord::Base
end

get '/' do
end
