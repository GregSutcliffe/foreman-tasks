module ForemanTasks
  module Concerns
    module HostgroupsControllerExtension
      extend ActiveSupport::Concern

      included do
        alias_method_chain :snapshot, :dynflow
      end

      def snapshot_with_dynflow
        @hostgroup = Hostgroup.find(params[:id])

        hash = HashWithIndifferentAccess.new({
          :name                => @hostgroup.name.downcase,
          :compute_resource_id => ComputeResource.first.id,
          :hostgroup_id        => @hostgroup.id,
          :build               => 1,
          :managed             => true,
          :compute_attributes  => {
            :flavor_ref          => 1,
            :network             => "public",
            :image_ref           => ComputeResource.first.images.first.uuid
          }
        })

        hash.merge!(params[:host]) if params[:host].present?

        task = ForemanTasks.async_task(::Actions::Foreman::Hostgroup::Snapshot,
                                       hash)

        render :json => {:task_id => task.id}, :status => 202
      rescue ::Foreman::Exception => e
        render :json => {'message'=>e.to_s}, :status => :unprocessable_entity
      end

    end
  end
end
