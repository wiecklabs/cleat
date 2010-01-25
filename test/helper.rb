require "rubygems"
require "pathname"
require "test/unit"
require Pathname(__FILE__).dirname.parent + "lib/cleat"
require "harbor/test/test"

DataMapper.setup :default, "postgres://localhost/cleat_test"
DataMapper.auto_migrate!

class Time

  class << self

    ##
    # Time.warp
    #   Allows you to stub-out Time.now to return a pre-determined time for calls to Time.now.
    #   Accepts a Fixnum to be added to the current Time.now, or an instance of Time
    #
    #   item.expires_at = Time.now + 10
    #   assert(false, item.expired?)
    #
    #   Time.warp(10) do
    #     assert(true, item.expired?)
    #   end
    ##
    def warp(time)
      @warp = time.is_a?(Fixnum) ? (Time.now + time) : time
      yield
      @warp = nil
    end

    alias original_now now

    def now
      @warp || original_now
    end

  end

end

class Date
  class << self
    def warp(days)
      @warp = days.is_a?(Fixnum) ? (Date.today + days) : days
      yield
      @warp = nil
    end

    alias original_today today

    def today
      @warp || original_today
    end
  end
end