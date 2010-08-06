class Cleat
  module Helpers
    def cleat(url)
      Cleat::UI::Link.new(Cleat::Link::shorten(url))
    end
  end
end

Harbor::ViewContext.send(:include, Cleat::Helpers)