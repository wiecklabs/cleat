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

  def click_count(start_date = '1970-1-1', end_date = Time.now)
    start_date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s) + 1
    session_clicks = Statistics::LinkSessionClick.count(:link_id => id, :created_at.gte => start_date, :created_at.lte => end_date)
    user_clicks = Statistics::LinkUserClick.count(:link_id => id, :created_at.gte => start_date, :created_at.lte => end_date)
    
    session_clicks + user_clicks
  end

  def click_stats_by_date(start_date = '1970-1-1', end_date = Time.now)
    start_date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s) + 1

    query = <<-SQL.margin
    SELECT stats.created_at, user_agents.remote_ip, stats.referrer, user_agents.raw, users.email
    FROM (
      SELECT created_at, referrer, session_id, user_id FROM statistics_link_user_clicks
      WHERE link_id = ? AND created_at BETWEEN ? AND ?
      UNION
      SELECT created_at, referrer, session_id, -1 as user_id FROM statistics_link_session_clicks
      WHERE link_id = ? AND created_at BETWEEN ? AND ?
    ) as stats
    LEFT JOIN user_agents ON stats.session_id = user_agents.session_id
    LEFT JOIN users ON stats.user_id = users.id
    ORDER BY stats.created_at ASC
    SQL

    repository.adapter.query(query, id, start_date, end_date, id, start_date, end_date)
  end

  def record_click(session, referrer = nil, framed = false)
    if session.user
      Statistics::LinkUserClick.create(
        :link_id => id,
        :session_id => session.id,
        :user_id => session.user.id,
        :referrer => referrer,
        :framed => framed
      )
    else    
      Statistics::LinkSessionClick.create(
        :link_id => id,
        :session_id => session.id,
        :referrer => referrer,
        :framed => framed
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