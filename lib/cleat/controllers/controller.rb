class Cleat::Controller
  
  attr_accessor :request, :response
  
  def show(key)
    response.redirect Cleat::Url::url(key)
  end
  
  def create(url)
    response.puts Cleat::Url::short(url)
  end
  
  def index
    response.render("cleat/index", :layout => nil)
  end
end