class Cleat::Link
  include DataMapper::Resource

  @@full_text_search_fields = [:title, :description, :destination]
  
  def self.full_text_search_fields
    @@full_text_search_fields
  end

  def self.active_conditions
    "now()::date >= start_date AND (end_date is null OR end_date >= now()::date)"
  end

  def self.expired_conditions
    "not (#{active_conditions})"
  end

  property :id, Serial
  property :destination, Text, :blank => false, :lazy => false

  property :title, String, :length => 255
  property :description, Text
  property :start_date, Date, :default => lambda { Date.today }
  property :end_date, Date

  property :custom_short_url, String, :length => 255

  property :created_at, DateTime

  after :create do |success|
    update_attributes(:title => "#{Date.today}:#{short}") if success && title.blank?
  end

  validates_present :destination, :start_date
  validates_format :custom_short_url,
    :with => /^(\w|-)+$/,
    :unless => lambda { |link| link.custom_short_url.blank? },
    :message => "Custom Short URL can only include numbers, letters, and dashes."

  def to_s
    destination
  end

  def active?
    ((today = Date.today) >= start_date) && (!end_date || end_date >= today)
  end

  def destination=(url)
    url = "http://#{url}" unless url =~ /^https?\:\/\//i
    attribute_set(:destination, url)
  end

  def short
    if new_record?
      raise StandardError.new("Cleat::Link must be saved to generate a short-url-key.")
    else
      @short ||= custom_short_url.blank? ? id.to_s(36) : custom_short_url
    end
  end

  def record_click(session)
    if session.user
      Statistics::LinkUserClick.create(
        :link_id => id,
        :session_id => session.id,
        :user_id => session.user.id
      )
    else    
      Statistics::LinkSessionClick.create(
        :link_id => id,
        :session_id => session.id
      )
    end
  end

  def self.shorten(url)
    url = "http://#{url}" unless url =~ /^https?\:\/\//i

    first(:destination => url) || create(:destination => url)
  end

  def self.base36?(string)
    string =~ /^[a-z0-9]+$/
  end

  def self.for(short, only_return_active = true)
    if base36?(short)
      conditions = ["id = ? OR custom_short_url = ?", short.to_i(36), short]
    else
      conditions = ["custom_short_url = ?", short]
    end

    conditions[0] = "#{active_conditions} AND #{conditions[0]}" if only_return_active

    instance = first(:conditions => conditions)
  end
end