class Cleat::Url
  include DataMapper::Resource

  property :id, Serial
  property :url, String, :length => (1..500), :blank => false
  property :created_at, DateTime

  SIXTYTWO = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a
  
  def to_s
    url
  end
  
  def short
    if new_record?
      raise StandardError.new("Cleat::Url must be saved to generate a short-url-key.")
    else
      unless @short
        if id == 0
          @short = "0"
        else
          @short = ""

          i = id
          
          while i > 0
            @short << SIXTYTWO[i.modulo(62)]
            i /= 62
          end

          @short.reverse!
        end
      end
      
      @short
    end
  end
  
  def self.short(url)
    url = "http://#{url}" unless url =~ /^https?\:\/\//i
    if Cleat::whitelist.any? { |domain| url =~ domain }
      instance = first(:url => url) || create(:url => url)
      instance.short
    else
      nil
    end
  end
  
  def self.url(short)
    if instance = get(short.scan(/./).inject(0) { |m,c| m * 62 + SIXTYTWO.index(c) })
      instance.url
    else
      nil
    end
  end
end