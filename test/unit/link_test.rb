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

    def test_short
      assert_raises(StandardError, "Calling Link#short on unsaved record should raise error") { Cleat::Link.new.short }

      automatic = Cleat::Link.create(:destination => "http://example.com/automatic")
      assert_equal automatic.id.to_s(36), automatic.short

      custom = Cleat::Link.create(:destination => "http://example.com/custom", :custom_short_url => "custom")
      assert_equal "custom", custom.short
    end

    def test_base36?
      assert Cleat::Link.base36?("a")
      assert Cleat::Link.base36?("a1k9")
      assert !Cleat::Link.base36?("test-1")
    end

    def test_link_for
      automatic = Cleat::Link.create(:destination => "http://example.com/automatic")
      assert_equal automatic, Cleat::Link.for(automatic.short)

      custom = Cleat::Link.create(:destination => "http://example.com/custom", :custom_short_url => "custom")
      assert_equal custom, Cleat::Link.for(custom.short)

      custom = Cleat::Link.create(:destination => "http://example.com/custom", :custom_short_url => "custom-2")
      assert_equal custom, Cleat::Link.for(custom.short)
    end
  end
end