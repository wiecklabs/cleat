module Statistics
  class LinkSessionClick
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :link_id, Integer
    property :session_id, String, :length => 255
    property :created_at, DateTime
  end
end