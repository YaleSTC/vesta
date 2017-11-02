class AddSubdomainToColleges < ActiveRecord::Migration[5.1]
  def change
    add_column :colleges, :subdomain, :string

    reversible do |dir|
      # set default subdomains for existing colleges
      dir.up do
        execute('SELECT * FROM colleges;').each do |c|
          subdomain = URI.encode_www_form_component(c['name'].downcase)
          time = Time.now.utc.strftime('%F %T')
          execute <<-SQL
            UPDATE colleges SET subdomain = '#{subdomain}',
                                updated_at = '#{time}'
                            WHERE colleges.id = #{c['id']};
          SQL
        end
      end
    end
    change_column_null :colleges, :subdomain, false
    add_index :colleges, :subdomain, unique: true
  end
end
