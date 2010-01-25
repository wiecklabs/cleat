require "pathname"
require Pathname(__FILE__).dirname + ".." + "helper"

module Unit
  class LinkTest < Test::Unit::TestCase
    def test_link_active?
      link = Cleat::Link.new(:start_date => Date.today)

      assert link.active?, "Link with blank end_date should be active"
      Date.warp(1) { assert link.active?, "Link with no end date and after start date should be active" }

      link.end_date = Date.today + 2
      assert link.active?, "Link with future end_date should be active"
      Date.warp(2) { assert link.active?, "Link should be active on end_date" }

      Date.warp(-1) { assert !link.active?, "Link with future start date should be inactive" }
      Date.warp(3) { assert !link.active?, "Link should not be active past end_date" }
    end
  end
end