module RdfstoreInstrumentation
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current["rdfstore_query_runtime"] = value
    end

    def self.runtime
      Thread.current["rdfstore_query_runtime"] ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def initialize
      super

      @odd_or_even = false
    end

    def odd?
      @odd_or_even = !@odd_or_even
    end

    def query(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      name = 'Rdfstore Query (%.1fms)' % [event.duration]

      query = format_query event.payload[:query]

      debug "  #{color(name, YELLOW, true)}  [ #{query} ]"
    end

    # produces: 'query: "foo" OR "bar", rows: 3, ...'
    def format_query(query)
      query.map{ |k, v| "#{k}: #{color(v, BOLD, true)}" }.join(', ')
    end

    def delete(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      name = 'Rdfstore Delete (%.1fms)' % [event.duration]

      debug "  #{color(name, YELLOW, true)} [ id: #{color(event.payload[:id], BOLD, true)} ]"
    end

    def commit(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      name = 'Rdfstore Commit (%1fms)' % [event.duration]

      debug "  #{color(name, YELLOW, true)}"
    end

    def logger
      Rails.logger
    end
  end
end