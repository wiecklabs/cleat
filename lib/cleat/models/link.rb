class Cleat::Link
  include DataMapper::Resource

  property :id, Serial
  property :destination, Text, :blank => false, :lazy => false

  property :title, String, :length => 255
  property :description, Text
  property :start_date, Date, :default => lambda { Date.today }
  property :end_date, Date

  property :custom_short_url, String, :length => 255

  property :created_at, DateTime

  validates_present :destination, :start_date
  validates_format :custom_short_url,
    :with => /^(\w|-)+$/,
    :unless => lambda { |link| link.custom_short_url.blank? },
    :message => "Custom Short URL can only include numbers, letters, and dashes."

  def to_s
    url
  end

  def short
    if new_record?
      raise StandardError.new("Cleat::Link must be saved to generate a short-url-key.")
    else
      @short ||= id.to_s(36)
    end
  end

  def self.shorten(url)
    url = "http://#{url}" unless url =~ /^https?\:\/\//i

    if Cleat::whitelist.any? { |domain| url =~ domain }
      instance = first(:destination => destination) || create(:destination => destination)
      instance.short
    else
      nil
    end
  end

  def self.url(short)
    if instance = get(short.to_i(36))
      instance.url
    else
      nil
    end
  end
end