class AddTenantToDelayedJob < ActiveRecord::Migration[5.1]
  def change
    add_column :delayed_jobs, :tenant, :string
  end
end
