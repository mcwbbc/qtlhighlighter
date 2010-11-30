module RdfstoreInstrumentation
  module ControllerRuntime
    extend ActiveSupport::Concern

    protected

    def append_info_to_payload(payload)
      super
      payload[:rdfstore_runtime] = RdfstoreInstrumentation::LogSubscriber.runtime
    end

    module ClassMethods
      def log_process_action(payload)
        messages, rdfstore_runtime = super, payload[:rdfstore_runtime]
        messages << ("Rdfstore: %.1fms" % rdfstore_runtime.to_f) if rdfstore_runtime
        messages
      end
    end
  end
end

