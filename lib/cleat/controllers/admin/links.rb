class Cleat::Admin::Links
  include PortAuthority::Authorization

  attr_accessor :request, :response, :mailer

  protect "Links", "list"
  def index(page, page_size, query = nil)
    return search(page, page_size, Cleat::Link.active_conditions, query)
  end

  protect "Links", "list"
  def expired(page, page_size, query = nil)
    return search(page, page_size, Cleat::Link.expired_conditions, query)
  end

  protect "Links", "create"
  def new
    response.render "admin/links/new", :link => Cleat::Link.new
  end

  protect "Links", "update"
  def edit(id)
    link = Cleat::Link.get(id)

    response.abort!(404) unless link

    response.render "admin/links/edit", :link => link
  end

  protect "Links", "create"
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

  protect "Links", "update"
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

  protect "Links", "delete"
  def delete(id)
    link = Cleat::Link.get(id)

    response.render "admin/links/delete", :link => link
  end

  protect "Links", "delete"
  def destroy(id)
    link = Cleat::Link.get(id)
    link.destroy

    response.message("success", "Link successfully deleted")
    response.redirect "/admin/links"
  end

  protect "Links", "statistics"
  def statistics(id, start_date, end_date)
    link = Cleat::Link.get(id)
    response.abort!(404) unless link

    start_date = Date.today if start_date.blank?
    end_date = Date.today if end_date.blank?

    response.render "admin/links/_statistics", :link => link, :start_date => start_date, :end_date => end_date
  end

  protect "Links", "statistics"
  def export_statistics(id, start_date, end_date)
    link = Cleat::Link.get(id)
    response.abort!(404) unless link

    start_date = Date.today if start_date.blank?
    end_date = Date.today if end_date.blank?

    csv = FasterCSV.generate do |csv|
      csv << ["Date", "IP Address", "Referrer", "User Agent", "User Email"]
      link.click_stats_by_date(start_date, end_date).each do |stat|
        ip = stat.remote_ip ? IPAddr.new(stat.remote_ip, Socket::AF_INET).to_s : nil
        csv << [stat.created_at.strftime("%Y-%m-%d"), ip, stat.referrer, stat.raw, stat.email] 
      end
    end
    filename = "link_statistics_"
    filename << (link.title.blank? ? link.id.to_s : link.title.gsub(/\W+/, '_'))
    response.send_file("#{filename}.csv", StringIO.new(csv), "text/csv")
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