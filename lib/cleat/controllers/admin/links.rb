class Cleat::Admin::Links

  attr_accessor :request, :response, :mailer

  def index
    response.render "admin/links/index"
  end

  def new
    response.render "admin/links/new", :link => Cleat::Link.new
  end

  def edit(id)
    link = Cleat::Link.get(id)

    response.abort!(404) unless link

    response.render "admin/links/edit", :link => link
  end

  def create(params)
    link = Cleat::Link.new(params)

    if link.save
      response.message("success", "Link successfully created.")
      response.redirect "/admin/links/#{link.id}"
    else
      response.errors << UI::ErrorMessages::DataMapperErrors.new(link)
      response.render "admin/links/new", :link => link
    end
  end

  def update(id, params)
    link = Cleat::Link.get(id)
    link.attributes = params

    if link.save
      response.message("success", "Link successfully updated.")
      response.redirect "/admin/links/#{link.id}"
    else
      response.errors << UI::ErrorMessages::DataMapperErrors.new(link)
      response.render "admin/links/edit", :link => link
    end
  end

end