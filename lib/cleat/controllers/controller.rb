class Cleat
  class Controller
    attr_accessor :request, :response

    def redirect(key)
      if link = Cleat::Link.for(key)
        link.record_click(request.session, request.referrer, false)

        response.redirect link.destination
      else
        response.abort!(404)
      end
    end

    def show(key)
      if link = Cleat::Link.for(key)
        link.record_click(request.session, request.referrer, true)

        response.render "cleat/frame", :link => link
      else
        response.abort!(404)
      end
    end
  end
end