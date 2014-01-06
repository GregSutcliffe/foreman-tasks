module Actions
  module Foreman
    module Host

      class ImportFacts < Actions::EntryAction

        def resource_locks
          :import_facts
        end

        def plan(host_type, host_name, facts, certname, proxy_id)
          host = ::Host::Base.importHost(host_name, certname, proxy_id)
          action_subject(host, :facts => facts)
        end

        def run
          ::User.as :admin do
            host           = ::Host.find(input[:host][:id])
            state          = host.importFacts(input[:facts])
            output[:state] = state
          end
        rescue Exception => e
          raise e unless e.message == 'ERF51-9911: Host is pending for Build'
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
