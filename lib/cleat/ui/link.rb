class Cleat
  module UI
    class Link
      def initialize(request, link, inline = false)
        host = request.env["HTTP_X_FORWARDED_SERVER"]
        host = request.env["HTTP_HOST"] if host.nil? || host.empty?

        port = if !request.env["HTTP_X_FORWARDED_SERVER"] && ((request.scheme == 'https' && request.port != 443) || (request.scheme == 'http' && request.port != 80))
          host[":#{request.port}"] ? nil : ":#{request.port}"
        end

        @url = "#{request.scheme}://#{host}#{port}/#{Cleat.prefix}#{link.short}#{"!" if inline}"
      end

      def to_s
        @url
      end
    end
  end
end