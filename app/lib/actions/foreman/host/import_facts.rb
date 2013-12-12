module Actions
  module Foreman
    module Host

      class ImportFacts < Actions::EntryAction

        def resource_locks
          :import_facts
        end

        def plan(host_type, host_name, facts, certname, proxy_id)
          host = host_type.importHost(host_name, certname, proxy_id)
          action_subject(host, :facts => facts)
        end

        def run
          User.as :admin do
            host           = ::Host.find(input[:host][:id])
            state          = host.importFacts(input[:facts])
            output[:state] = state
          end
        end

        def humanized_name
          _("Import facts")
        end

        def humanized_input
          input[:host] && input[:host][:name]
        end

      end
    end
  end
end
