require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_many :favs
end

class Fav < ActiveRecord::Base
  scope :has_tag_id, -> (tweet_tag) {
    joins(:tags).where('tags.id = ?', tweet_tag)
  }

  belongs_to :user
  has_many :tags
  has_many :medias
end

class Gif < ActiveRecord::Base
end