class CreateLatestFavsTweets < ActiveRecord::Migration[4.2]
  def change
    create_table :latest_favs_tweets do |t|
      t.integer :status_id
      t.timestamps
    end
  end
end
