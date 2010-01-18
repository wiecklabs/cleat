class Cleat::Admin::Links

  attr_accessor :request, :response, :mailer

  def index(page, page_size, query = nil)
    return search(page, page_size, Cleat::Link.active_conditions, query)
  end

  def expired(page, page_size, query = nil)
    return search(page, page_size, Cleat::Link.expired_conditions, query)
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
      response.redirect "/admin/links"
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

  private

  def search(page, page_size, conditions, query)
    search = Cleat::Link::Search.new(page, page_size, { :conditions => [conditions] }, query)

    if request.xhr?
      response.render "admin/links/_list", :search => search, :layout => nil
    else
      response.render "admin/links/index", :search => search
    end
  end

end