require "pathname"
require "rubygems"

gem "harbor", "~> 0.9"
require "harbor"
require "harbor/mailer"

gem "dm-core"
require "dm-core"

Harbor::View::path.unshift(Pathname(__FILE__).dirname + "cleat" + "views")

class Cleat < Harbor::Application

  autoload :Controller, (Pathname(__FILE__).dirname + "cleat" + "controllers" + "controller").to_s
    
  def self.routes(services = self.services)
    raise ArgumentError.new("+services+ must be a Harbor::Container") unless services.is_a?(Harbor::Container)

    Harbor::Router.new do
      using services, Cleat::Controller do
        get("/~") { |controller| controller.index }
        get("/~:key") { |controller, request| controller.show(request["key"]) }
        post("/~") { |controller, request| controller.create(request["url"]) }
      end
    end
    
  end
  
  def self.fake!
    DataMapper::auto_migrate!
    
    gem "faker"
    require "faker"
    
    @whitelist = [/^http\:\/\/.+/i]
    10_000.times do |i|
      Cleat::Url::short("http://#{Faker::Internet::domain_name}/#{i}")
    end
  end
  
  @whitelist = []
  def self.whitelist
    @whitelist
  end
  
  def self.whitelist!(domain)
    @whitelist << /^(https?\:\/\/)#{domain.sub(/https?\:\/\//i, "")}/i
  end
end

require Pathname(__FILE__).dirname + "cleat" + "models" + "url"

module Harbor
  class ViewContext
    def cleat(path)
      url = path
      unless Cleat::whitelist.any? { |domain| url =~ domain }
        if url =~ /^\//
          url = "#{request.host}#{url}"
        else
          url = "#{request.host}/#{url}"
        end
      end
      url = "http://#{url}" unless url =~ /^http\:\/\//i
      
      Cleat::Url::short(url)
    end
  end
end
