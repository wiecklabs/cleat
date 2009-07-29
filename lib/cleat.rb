require "pathname"
require "rubygems"

gem "harbor", "~> 0.9"
require "harbor"
require "harbor/mailer"

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
end

require (Pathname(__FILE__).dirname) + "cleat" + "uri"