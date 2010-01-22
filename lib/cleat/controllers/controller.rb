class Cleat
  class Controller
    attr_accessor :request, :response

    def redirect(short_url)
      if link = Cleat::Link.active.first(:short_url => short_url)
        link.record_click(request.session, request.referrer, false)

        response.redirect link.destination
      else
        response.abort!(404)
      end
    end

    def show(short_url)
      if link = Cleat::Link.active.first(:short_url => short_url)
        link.record_click(request.session, request.referrer, true)

        response.render "cleat/frame", :link => link
      else
        response.abort!(404)
      end
    end
  end
end