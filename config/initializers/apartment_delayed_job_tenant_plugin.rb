# frozen_string_literal: true

# Plugin module to allow a delayed job to store the tenant for which it should
# run. Inspired by https://github.com/influitive/apartment/pull/436
class ApartmentDelayedJobTenantPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    # save the current tenant before enqueuing the job
    lifecycle.before :enqueue do |job|
      job.tenant = Apartment::Tenant.current
    end

    # switch to the saved tenant before deserializing the job
    lifecycle.around :perform do |worker, job, *args, &block|
      Apartment::Tenant.switch(job.tenant) do
        block.call(worker, job, *args)
      end
    end
  end
end

# Register the plugin
Delayed::Worker.plugins << ApartmentDelayedJobTenantPlugin
