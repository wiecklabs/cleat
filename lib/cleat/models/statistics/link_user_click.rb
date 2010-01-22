module Statistics
  class LinkUserClick
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :link_short_url, Text
    property :user_id, Integer
    property :session_id, String, :length => 255
    property :referrer, Text
    property :framed, Boolean
    property :created_at, DateTime
  end
end