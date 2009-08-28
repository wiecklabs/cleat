require "open-uri"

class Cleat::Controller
  
  attr_accessor :request, :response
  
  def show(key, inline = false)
    if url = Cleat::Url::url(key)
      if inline
        response.puts open(url)
      else
        response.redirect url
      end
    else
      response.status = 404 # Not Found
    end
  end
  
  def create(url)
    if short = Cleat::Url::short(url)
      response.render "cleat/show", :url => url, :layout => nil
    else
      # Didn't pass the whitelist filter.
      response.status = 403 # Forbidden
    end
  end
  
  def index
    response.render("cleat/index", :layout => nil)
  end
end