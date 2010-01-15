require "pathname"
require Pathname(__FILE__).dirname + ".." + "helper"

module Integration
  class ControllerTest < Test::Unit::TestCase
    def setup
      DataMapper.auto_migrate!
      User.create!

      @container = Harbor::Container.new
      @container.register(:controller, Cleat::Controller)
      @container.register(:request, Harbor::Test::Request)
    end

    def test_redirect_with_no_link
      response = Harbor::Test::Response.new
      assert_throws(:abort_request) { @container.get(:controller, :response => response).redirect("1") }
      assert_equal 404, response.status
    end

    def test_redirect_with_expired_link
      link = Cleat::Link.create(:destination => "example.com", :start_date => Date.today - 2, :end_date => Date.today - 1)

      response = Harbor::Test::Response.new
      assert_throws(:abort_request) { @container.get(:controller, :response => response).redirect("1") }
      assert_equal 404, response.status
    end

    def test_redirect_with_active_link
      link = Cleat::Link.create(:destination => "example.com")

      response = Harbor::Test::Response.new
      assert_nothing_thrown { @container.get(:controller, :response => response).redirect("1") }
      assert_equal 303, response.status
      assert_equal "http://example.com", response.headers["Location"]
    end

    def test_redirect_stats
      link = Cleat::Link.create(:destination => "example.com")

      response = Harbor::Test::Response.new
      @container.get(:controller, :response => response).redirect("1")

      assert_equal 1, Statistics::LinkSessionClick.count(:link_id => 1)

      response = Harbor::Test::Response.new
      @container.get(:controller, :response => response, :session => { :user_id => 1 }).redirect("1")

      assert_equal 1, Statistics::LinkUserClick.count(:link_id => 1)
    end

  end
end
