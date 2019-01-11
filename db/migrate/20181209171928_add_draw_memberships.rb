class AddDrawMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :draw_memberships do |t|
      t.references :user, null: false, foreign_key: { to_table: 'shared.users' }
      t.references :draw
      t.references :old_draw
      t.integer :intent, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    schema = ActiveRecord::Base.connection.schema_search_path.delete('\\"')

    # This ensures that the foreign keys are removed if the migration is rolled back.
    #   It is added now instead of during the table creation for readability purposes.
    add_foreign_key :draw_memberships, :draws
    add_foreign_key :draw_memberships, :draws, column: :old_draw_id

    reversible do |dir|
      dir.up do
        if schema == 'public'
        elsif schema == 'shared'
          # Create draw memberships for all students and reps and store them temporarily in shared.draw_memberships
          # This runs before every other tenant because of how Apartment is configured

          # Foreign key constraints are removed for the time being because the references will be incorrect

          remove_foreign_key :draw_memberships, column: :draw_id
          remove_foreign_key :draw_memberships, column: :old_draw_id

          execute <<-SQL
            INSERT INTO draw_memberships (user_id, draw_id, old_draw_id, intent, created_at, updated_at)
            SELECT users.id, users.draw_id, users.old_draw_id, users.intent, users.created_at, users.updated_at
            FROM users
            WHERE role IN (0, 2);
          SQL
        else
          college_id = College.find_by(subdomain: schema)&.id
          # This takes place in every college
          # Migrate the current tenant's draw_memberships from the shared schema to the current schema
          # This will ONLY migrate draw memberships for users that have joined groups (i.e. have memberships associated with them), lead groups, or have room assignments
          execute <<~SQL
            INSERT INTO draw_memberships (user_id, draw_id, old_draw_id, intent, created_at, updated_at)
            SELECT old.user_id, old.draw_id, old.old_draw_id, old.intent, old.created_at, old.updated_at
            FROM (
              SELECT shared.draw_memberships.user_id, shared.draw_memberships.draw_id, shared.draw_memberships.old_draw_id, shared.draw_memberships.intent, shared.draw_memberships.created_at, shared.draw_memberships.updated_at
              FROM shared.draw_memberships
              INNER JOIN shared.users
              ON shared.users.id = shared.draw_memberships.user_id
              LEFT JOIN memberships
              ON shared.users.id = memberships.user_id
              LEFT JOIN groups
              ON shared.users.id = groups.leader_id
              LEFT JOIN room_assignments
              ON shared.users.id = room_assignments.user_id
              WHERE shared.users.college_id = #{college_id}
                AND ( memberships.id IS NOT NULL OR groups.id IS NOT NULL OR room_assignments.id IS NOT NULL OR shared.draw_memberships.draw_id IS NOT NULL )
            ) AS old
          SQL
        end

        if schema == College.last&.subdomain
          # Once all data is migrated into each tenant (i.e. after the last college receives its draw_memberships)
          #   delete the temporary shared.draw_memberships data
          # Since the data will now have referential integrity we can add back the foreign key constraints
          ActiveRecord::Base.connection.schema_search_path = "\"shared\""

          execute <<~SQL
            TRUNCATE TABLE shared.draw_memberships RESTART IDENTITY CASCADE;
          SQL

          add_foreign_key :draw_memberships, :draws
          add_foreign_key :draw_memberships, :draws, column: :old_draw_id

          ActiveRecord::Base.connection.schema_search_path = "\"#{schema}\""
        end
      end

      dir.down do
        if schema != 'shared' && schema != 'public'
          college_id = College.find_by(subdomain: schema)&.id

          # Update shared.users with the data from their currently active draw_memberships
          execute <<~SQL
            UPDATE shared.users
            SET draw_id = mapping.draw_id, old_draw_id = mapping.old_draw_id, intent = mapping.intent
            FROM (
              SELECT draw_memberships.draw_id, draw_memberships.old_draw_id, draw_memberships.intent, shared.users.id
              FROM draw_memberships
              INNER JOIN shared.users
              ON draw_memberships.user_id = shared.users.id
              WHERE shared.users.college_id = #{college_id} AND draw_memberships.active = TRUE
            ) AS mapping
            WHERE mapping.id = shared.users.id
          SQL
        end
      end
    end

    add_reference :groups, :leader_draw_membership, foreign_key: { to_table: :draw_memberships }, index: { unique: true }

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE groups SET leader_draw_membership_id =
            (SELECT id
             FROM draw_memberships
             WHERE draw_memberships.user_id = groups.leader_id);
        SQL
      end
      dir.down do
        execute <<~SQL
          UPDATE groups SET leader_id =
            (SELECT user_id
             FROM draw_memberships
             WHERE draw_memberships.id = groups.leader_draw_membership_id);
        SQL
        # Adds a "not null" constraint to groups.leader_id
        change_column_null :groups, :leader_id, false
      end
    end

    add_reference :memberships, :draw_membership, foreign_key: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE memberships SET draw_membership_id =
            (SELECT id
             FROM draw_memberships
             WHERE memberships.user_id = draw_memberships.user_id);
        SQL
      end
      dir.down do
        execute <<~SQL
          UPDATE memberships SET user_id =
            (SELECT user_id
             FROM draw_memberships
             WHERE draw_memberships.id = memberships.draw_membership_id );
        SQL
      end
    end

    add_reference :room_assignments, :draw_membership, foreign_key: true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE room_assignments SET draw_membership_id =
            (SELECT id
             FROM draw_memberships
             WHERE room_assignments.user_id = draw_memberships.user_id);
        SQL
      end
      dir.down do
        execute <<~SQL
          UPDATE room_assignments SET user_id =
            (SELECT user_id
             FROM draw_memberships
             WHERE draw_memberships.id = room_assignments.draw_membership_id );
        SQL
      end
    end

    add_column :draws, :active, :boolean, default: true, null: false

    reversible do |dir|
      dir.up do
        remove_reference :memberships, :user
        remove_reference :room_assignments, :user
      end
      dir.down do
        add_reference :memberships, :user, foreign_key: { to_table: 'shared.users' }
        add_reference :room_assignments, :user, foreign_key: { to_table: 'shared.users' }
      end
    end

    remove_reference :groups, :leader, index: true
    remove_reference :users, :draw
    remove_column :users, :old_draw_id, :integer
    remove_column :users, :intent, :integer, default: 0, null: false
  end
end
