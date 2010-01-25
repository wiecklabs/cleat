class Cleat
  module Helpers
    def cleat(url, inline = false)
      Cleat::UI::Link.new(Cleat::Link::shorten(url, inline))
    end
  end
end

Harbor::ViewContext.send(:include, Cleat::Helpers)