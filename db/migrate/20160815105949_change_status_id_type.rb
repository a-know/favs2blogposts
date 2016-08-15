class ChangeStatusIdType < ActiveRecord::Migration[4.2]
  def change
    change_column :latest_favs_tweets, :status_id, :string
  end
end
