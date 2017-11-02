class RemoveSiteUrlFromColleges < ActiveRecord::Migration[5.1]
  def change
    remove_column :colleges, :site_url, :string, null: false
  end
end
