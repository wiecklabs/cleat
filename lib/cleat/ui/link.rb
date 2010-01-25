class Cleat
  module UI
    class Link
      def initialize(link, inline = false)
        @url = "#{(Cleat::base_url + "/").squeeze("/")}#{Cleat.prefix}#{link.short_url}#{"!" if inline}"
      end

      def to_s
        @url
      end
    end
  end
end