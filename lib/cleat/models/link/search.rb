class Cleat::Link::Search

  DEFAULT_PAGE = 1
  DEFAULT_PAGE_SIZE = 100
  
  attr_reader :page, :page_size, :options, :query
  
  def initialize(page, page_size, options, query)
    if (@page = page.to_i.abs) == 0
      @page = DEFAULT_PAGE
    end

    if (@page_size = page_size.to_i.abs) == 0
      @page_size = DEFAULT_PAGE_SIZE
    end
    
    @result_offset = (@page - 1) * @page_size

    @options = options.is_a?(Hash) ? options : {}
    @query = query
  end

  def links
    execute_search
    @links
  end

  def each
    links.each { |link| yield link }
  end
  
  def total_count
    execute_search
    @total_count
  end

  private
  
  def execute_search
    return if @search_executed
    
    @search_executed = true

    order = [:created_at.desc]
    counter_options = @options.dup
    filter_options = { :order => order, :offset => @result_offset, :limit => @page_size }.merge!(counter_options)

    if @query && !@query.blank?
      ids = full_text_search_with_sql

      if ids.any?
        counter_options[:id] = ids
        filter_options[:id] = ids
      else
        # We've pre-filtered, and came back with 0 results.  There's no way applying additional
        # filters will return any more results, so fail fast.
        @total_count, @links = 0, []
        return false
      end
    end

    # The list of links representing the current page (@page)
    @links = Cleat::Link.all(filter_options)
    
    # The number total links that match the search query and options
    @total_count = Cleat::Link.count(counter_options)

    true
  end

  ##
  # Return a list of Account ID's from SQL that match the query
  ##
  def full_text_search_with_sql
    search_query = <<-SQL.margin
      SELECT id
      FROM cleat_links
      WHERE
        #{Cleat::Link.full_text_search_fields.map { |field_name| full_text_search_fragment(field_name) }.join(' OR ')}
    SQL

    parameters = ["%#{@query}%"] * Cleat::Link.full_text_search_fields.size
    repository(:default).adapter.query(search_query, *parameters)
  end

  def full_text_search_fragment(field_name)
    if Cleat::Link.repository.adapter.class.name =~ /postgres/i
      "#{field_name} ILIKE ?"
    else
      "#{field_name} LIKE ?"
    end
  end
  
end