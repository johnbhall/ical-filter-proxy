module IcalFilterProxy
  class WebApp
    attr_accessor :filters

    def initialize(filters)
      self.filters = filters
    end

    def call(env)
      request = Rack::Request.new(env)

      requested_filter = request.path_info.sub(/^\//, '')
      ical_filter = filters[requested_filter]

      if ical_filter
        if request.params['key'] == ical_filter[:api_key]
          [200, {'Content-Type' => 'text/calendar'}, [ical_filter[:calendar].filtered_calendar]]
        else
          [403, {'Content-Type' => 'text/plain'}, ['Authentication Incorrect']]
        end
      else
        [404, {'Content-Type' => 'text/plain'}, ['Calendar not found']]
      end
    end

    private

    def find_filter(filter_name)
      filters.find { |filter| filter.name == filter_name }
    end
  end
end
