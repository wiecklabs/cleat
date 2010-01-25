class Cleat::Link
  include DataMapper::Resource

  def self.auto_upgrade!(repository_name = self.repository_name)
    repository(repository_name) do |r|
      unless r.adapter.storage_exists?(storage_name(repository_name))
        auto_migrate_up!(repository_name)
      end
    end
  end

  def self.auto_migrate_down!(repository_name = self.repository_name)
    repository(repository_name) do |r|
      r.adapter.execute(<<-SQL)
      DROP TABLE IF EXISTS cleat_links;
      DROP TABLE IF EXISTS cleat_forbidden_words;
      DROP SEQUENCE IF EXISTS cleat_links_id_seq;
      SQL
    end
  end

  def self.auto_migrate_up!(repository_name = self.repository_name)
    create_table = <<-SQL
    create table cleat_links (
      short_url text primary key not null default cleat_link_next_key(),
      destination text not null,
      title varchar(255),
      description text,
      start_date date default 'now()',
      end_date date,
      created_at timestamp without time zone default 'now()'
    );
    CREATE SEQUENCE cleat_links_id_seq;
    SQL

    functions = Dir[Pathname(__FILE__).dirname.parent + "sql/*.sql"].map { |file| File.read(file) }

    repository(repository_name) do |r|
      r.adapter.execute(create_table)
      functions.each { |function| r.adapter.execute(function) }
    end
  end

  @@full_text_search_fields = [:title, :description, :destination]
  
  def self.full_text_search_fields
    @@full_text_search_fields
  end

  def self.active
    all(:conditions => [active_conditions])
  end

  def self.active_conditions
    "now()::date >= start_date AND (end_date is null OR end_date >= now()::date)"
  end

  def self.expired_conditions
    "not (#{active_conditions})"
  end

  property :short_url, Text, :key => true, :serial => true
  property :destination, Text, :blank => false, :lazy => false

  property :title, String, :length => 255
  property :description, Text
  property :start_date, Date, :default => lambda { Date.today }
  property :end_date, Date

  property :created_at, DateTime

  validates_present :destination, :start_date
  validates_format :short_url,
    :with => /^(\w|-)+$/,
    :unless => lambda { |link| link.short_url.blank? },
    :message => "Custom Short URL can only include numbers, letters, and dashes."

  validates_is_unique :short_url, :unless => lambda { |link| link.short_url.blank? }

  def to_s
    destination
  end

  def active?
    ((today = Date.today) >= start_date) && (!end_date || end_date >= today)
  end

  def destination=(url)
    unless url.blank?
      url = "http://#{url}" unless url =~ /^https?\:\/\//i
    end
    attribute_set(:destination, url)
  end

  def custom_short_url=(short_url)
    attribute_set(:short_url, short_url) unless short_url.blank?
  end

  def click_count(start_date = '1970-1-1', end_date = Time.now)
    start_date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s) + 1
    session_clicks = Statistics::LinkSessionClick.count(:link_short_url => short_url, :created_at.gte => start_date, :created_at.lte => end_date)
    user_clicks = Statistics::LinkUserClick.count(:link_short_url => short_url, :created_at.gte => start_date, :created_at.lte => end_date)
    
    session_clicks + user_clicks
  end

  def click_stats_by_date(start_date = '1970-1-1', end_date = Time.now)
    start_date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s) + 1

    query = <<-SQL.margin
    SELECT stats.created_at, user_agents.remote_ip, stats.referrer, user_agents.raw, users.email
    FROM (
      SELECT created_at, referrer, session_id, user_id FROM statistics_link_user_clicks
      WHERE link_short_url = ? AND created_at BETWEEN ? AND ?
      UNION
      SELECT created_at, referrer, session_id, -1 as user_id FROM statistics_link_session_clicks
      WHERE link_short_url = ? AND created_at BETWEEN ? AND ?
    ) as stats
    LEFT JOIN user_agents ON stats.session_id = user_agents.session_id
    LEFT JOIN users ON stats.user_id = users.id
    ORDER BY stats.created_at ASC
    SQL

    repository.adapter.query(query, short_url, start_date, end_date, short_url, start_date, end_date)
  end

  def record_click(session, referrer = nil, framed = false)
    if session.user
      Statistics::LinkUserClick.create(
        :link_short_url => short_url,
        :session_id => session.id,
        :user_id => session.user.id,
        :referrer => referrer,
        :framed => framed
      )
    else    
      Statistics::LinkSessionClick.create(
        :link_short_url => short_url,
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

end