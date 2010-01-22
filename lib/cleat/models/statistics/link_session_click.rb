module Statistics
  class LinkSessionClick
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :link_short_url, Text
    property :session_id, String, :length => 255
    property :referrer, Text
    property :framed, Boolean
    property :created_at, DateTime
  end
end