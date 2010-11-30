require 'sparql/client'

VIRTUOSO_CONFIG = YAML::load_file(File.join(Rails.root, 'config', 'virtuoso.yml'))[Rails.env]
VIRTUOSO_SERVER = SPARQL::Client.new("http://#{VIRTUOSO_CONFIG['host']}:#{VIRTUOSO_CONFIG['port']}/sparql")

require 'rdfstore_instrumentation/log_subscriber'
require 'rdfstore_instrumentation/controller_runtime'

RdfstoreInstrumentation::LogSubscriber.attach_to(:rdfstore)

ActiveSupport.on_load(:action_controller) do
 include RdfstoreInstrumentation::ControllerRuntime
end
