require "pathname"
require "rubygems"

gem "harbor", ">= 0.9"
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
        get(/^\/#{Regexp.escape(Cleat.prefix)}$/) { |controller| controller.index }
        
        get(/^\/#{Regexp.escape(Cleat.prefix)}(.*)$/) do |controller, request|            
          if request.path =~ /^\/#{Regexp.escape(Cleat.prefix)}(.*)$/
            key = $1
            if key[-1] == ?!
              controller.show(key[0...-1], true)
            else
              controller.show(key, false)
            end
          end
        end
        post(/^\/#{Regexp.escape(Cleat.prefix)}$/) { |controller, request| controller.create(request["url"]) }
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
    @whitelist << /^(https?\:\/\/)?#{domain.sub(/https?\:\/\//i, "")}/i
  end

  @prefix = '~'
  def self.prefix
    @prefix
  end
  
  def self.prefix=(new_prefix)
    @prefix = new_prefix
  end

end

require Pathname(__FILE__).dirname + "cleat" + "models" + "url"

module Harbor
  class ViewContext
    def cleat(path)
      url = path

      # We may be behind mod_proxy and need to check the forwarded server variable...
      host = request.env["HTTP_X_FORWARDED_SERVER"]
      host = request.env["HTTP_HOST"] if host.nil? || host.empty?

      port = if !request.env["HTTP_X_FORWARDED_SERVER"] && ((request.scheme =~ /https/ && request.port != 443) || (request.scheme =~ /http/ && request.port != 80))
        ":#{request.port}"
      else
        nil
      end

      if Cleat::whitelist.any? { |domain| url =~ domain }
        url = "#{host}#{port}/#{url.sub(/^\//, '')}"
      else
        return nil
      end
      url = "http://#{url}" unless url =~ /^http\:\/\//i
      
      cleated = "#{request.scheme}://#{host}#{port}/#{Cleat.prefix}#{Cleat::Url::short(url)}"
      cleated
    end
  end
end
