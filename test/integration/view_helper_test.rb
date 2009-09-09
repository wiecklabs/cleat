require "pathname"
require "uri"
require Pathname(__FILE__).dirname + ".." + "helper"

module Integration

  class ViewHelperTest < Test::Unit::TestCase
  
    def setup
      Cleat::Url.auto_migrate!
    end
  
    def test_relative_path_link_from_request
      link = request("http://www.example.com/the/page/your/on").cleat_link_to("/relative/destination/url")
    
      assert_equal("http://www.example.com/relative/destination/url", link.destination_url)
      assert_equal("http://www.example.com/~1", link.display_url)
    end

    def test_relative_path_link_from_request_with_standard_port
      link = request("http://www.example.com:80/the/page/your/on").cleat_link_to("/relative/destination/url")
      assert_equal("http://www.example.com/relative/destination/url", link.destination_url)
      assert_equal("http://www.example.com/~1", link.display_url)

      link = request("https://www.example.com:443/the/page/your/on").cleat_link_to("/relative/destination/url")
      assert_equal("https://www.example.com/relative/destination/url", link.destination_url)
      assert_equal("https://www.example.com/~2", link.display_url)
    end

    def test_relative_path_link_from_request_with_non_standard_port
      link = request("http://www.example.com:1337/the/page/your/on").cleat_link_to("/relative/destination/url")
      
      assert_equal("http://www.example.com:1337/relative/destination/url", link.destination_url)
      assert_equal("http://www.example.com:1337/~1", link.display_url)
    end
    
    def test_absolute_path_link_from_request
      link = request("http://www.example.com/the/page/your/on").cleat_link_to("http://www.anotherexample.com/this/is/a/sample/path")
      
      assert_equal("http://www.anotherexample.com/this/is/a/sample/path", link.destination_url)
      assert_equal("http://www.example.com/~1", link.display_url)
    end
    
    def test_absolute_path_link_from_request_with_non_standard_port
      link = request("http://www.example.com:1337/the/page/your/on").cleat_link_to("http://www.anotherexample.com/this/is/a/sample/path")
      
      assert_equal("http://www.anotherexample.com/this/is/a/sample/path", link.destination_url)
      assert_equal("http://www.example.com:1337/~1", link.display_url)
    end
    
    def test_relative_path_link_from_forwarded_request
      link = request("http://127.0.0.1:1337/the/page/your/on", "www.example.com").cleat_link_to("/relative/destination/url")
      
      assert_equal("http://www.example.com/relative/destination/url", link.destination_url)
      assert_equal("http://www.example.com/~1", link.display_url)
    end
    
    def test_absolute_path_link_from_forwarded_request
      link = request("http://127.0.0.1:1337/the/page/your/on", "www.example.com").cleat_link_to("http://www.anotherexample.com/this/is/a/sample/path")
      
      assert_equal("http://www.anotherexample.com/this/is/a/sample/path", link.destination_url)
      assert_equal("http://www.example.com/~1", link.display_url)
    end

    private
    
    NO_APP = nil
    
    def request(request_url, forwarded_for = nil)
      uri = URI.parse(request_url)

      request = Harbor::Request.new(NO_APP, Rack::MockRequest.env_for(request_url, {
        'REQUEST_PATH' => uri.path,
        'HTTP_HOST' => uri.host
      }))

      if forwarded_for
        request.env['HTTP_X_FORWARDED_SERVER'] = forwarded_for
      end
      
      LinkHelper.new(request)
    end
    
    class LinkHelper
      def initialize(request); @request = request; end
      def cleat_link_to(path); Cleat::UI::Link.new(@request, path) end
    end
    
  end

end