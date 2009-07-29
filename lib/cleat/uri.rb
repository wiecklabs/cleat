class Cleat::Uri
  
  SIXTYTWO = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a
  
  def initialize(uri)
    @uri = uri
    
    i = @uri.hash
    
    if i == 0
      @short = "0"
    else
      @short = ""
      
      while i > 0
        @short << SIXTYTWO[i.modulo(62)]
        i /= 62
      end
      
      @short.reverse!
    end
      
  end
  
  def short
    @short
  end
  
  def to_s
    @uri.to_s
  end
end