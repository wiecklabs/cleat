class Cleat
  module UI    
    class Link

      def initialize(request, path)
        @request, @path = request, path

        @valid = (path =~ /^http/) ? Cleat::whitelist.any? { |domain| @path =~ domain } : true

        # We may be behind mod_proxy and need to check the forwarded server variable...
        @host = @request.env["HTTP_X_FORWARDED_SERVER"]
        @host = @request.env["HTTP_HOST"] if @host.nil? || @host.empty?
  
        @port = if !@request.env["HTTP_X_FORWARDED_SERVER"] && ((@request.scheme == 'https' && @request.port != 443) || (@request.scheme == 'http' && @request.port != 80))
          @host[":#{@request.port}"] ? nil : ":#{@request.port}"
        else
          nil
        end
      end
      
      ##
      # Builds the url that this Cleat will link to.  If the path that this instance was created with starts with 'http',
      # the entire path will be stored, and the current request information will be ignored.  Otherwise, the current
      # requests hostname, and port (if non-standard) are used.
      ##
      def destination_url
        return nil unless @valid

        @destination_url ||= if @path[/^http/]
          @path
        else
          "#{@request.scheme}://#{@host}#{@port}/#{@path.sub(/^\//, '')}"
        end
      end
      
      ##
      # Builds a url that can be used on the UI that can be used to redirect to the +destination_url+.  The request
      # scheme, host (or the proxied host), and port (if non standard) are used.
      ##
      def display_url
        return nil unless @valid

        @display_url ||= "#{@request.scheme}://#{@host}#{@port}/#{Cleat.prefix}#{Cleat::Url::short(self.destination_url)}"
      end
      
      alias to_s display_url

    end
  end
end