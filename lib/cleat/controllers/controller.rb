class Cleat::Controller
  
  attr_accessor :request, :response
  
  def show(key)
    response.puts "http://localhost:3000/"
  end
  
  def create(url)
    response.puts Cleat::Uri.new(url).short
  end
  
  def index
    response.render("cleat/index", :layout => nil)
  end
end