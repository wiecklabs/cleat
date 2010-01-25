class Cleat
  class Controller
    attr_accessor :request, :response

    def redirect(short_url)
      if link = Cleat::Link.active.first(:short_url => short_url.downcase)
        link.record_click(request.session, request.referrer, false)

        response.redirect link.destination
      else
        not_found!
      end
    end

    def show(short_url)
      if link = Cleat::Link.active.first(:short_url => short_url.downcase)
        link.record_click(request.session, request.referrer, true)

        response.render "cleat/frame", :link => link
      else
        not_found!
      end
    end

    private

    def not_found!
      response.status = 404
      response.render "cleat/not_found"
    end
  end
end