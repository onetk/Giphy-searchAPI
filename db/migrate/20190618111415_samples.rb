class Samples < ActiveRecord::Migration
  def change
    create_table :gifs do |t|
        t.string :gif_id
        t.string :gif_url
        t.datetime :trend_datetime
        t.datetime :upload_datetime
    end
  end
end
