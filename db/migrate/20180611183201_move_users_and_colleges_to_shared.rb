class MoveUsersAndCollegesToShared < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :college
    remove_foreign_key :room_assignments, :users

    reversible do |dir|
      schema = ActiveRecord::Base.connection.schema_search_path.delete('\\"')

      dir.up do
        # move colleges to new shared tenant
        if schema == 'public'
          execute <<-SQL
          INSERT INTO shared.colleges (#{college_attribute_list})
          SELECT #{college_attribute_list}
          FROM colleges;

          TRUNCATE TABLE colleges RESTART IDENTITY;
          SQL
        end

        # move users to new shared tenant and update foreign keys
        if schema != 'public' && schema != 'shared'
          execute <<-SQL
          /* add the college id to all non-superusers */
          UPDATE users SET college_id =
            (SELECT id FROM shared.colleges WHERE subdomain = '#{schema}')
          WHERE role != 3;

          /* add all users from the current tenant to the shared tenant.
             avoid adding any users that already exist in the shared tenant. */
          INSERT INTO shared.users (#{user_attribute_list})
          SELECT #{user_attribute_list}
          FROM users
          WHERE email NOT IN
            (SELECT email FROM shared.users)
          OR username NOT IN
            (SELECT username FROM shared.users);

          /* update user_id references for room_assignments from users
             in the current schema to users in the shared schema */
          UPDATE room_assignments SET user_id = joined_ids.new_id
          FROM (SELECT shared.users.id AS new_id, #{schema}.users.id AS old_id
                FROM shared.users
                INNER JOIN #{schema}.users ON CASE WHEN shared.users.username IS NULL
                                              THEN shared.users.email = #{schema}.users.email
                                              ELSE shared.users.username = #{schema}.users.username
                                              END) AS joined_ids
          WHERE joined_ids.old_id = user_id;

          /* update user_id references for memberships from users
             in the current schema to users in the shared schema */
          UPDATE memberships SET user_id = joined_ids.new_id
          FROM (SELECT shared.users.id AS new_id, #{schema}.users.id AS old_id
                FROM shared.users
                INNER JOIN #{schema}.users ON CASE WHEN shared.users.username IS NULL
                                              THEN shared.users.email = #{schema}.users.email
                                              ELSE shared.users.username = #{schema}.users.username
                                              END) AS joined_ids
          WHERE joined_ids.old_id = user_id;

          TRUNCATE TABLE users RESTART IDENTITY;
          SQL
        end
      end

      dir.down do
        if schema == 'shared'
          execute <<-SQL
          /* add colleges back to the public schema */
          INSERT INTO public.colleges (#{college_attribute_list})
          SELECT #{college_attribute_list}
          from shared.colleges;
          SQL

          execute('SELECT * FROM public.colleges;').each do |college|

            subdomain = college['subdomain']

            execute <<-SQL
            /* add superusers and superadmins to all college tenants */
            INSERT INTO #{subdomain}.users (#{user_attribute_for_rollback_list})
            SELECT #{user_attribute_for_rollback_list}
            FROM shared.users
            WHERE college_id IS NULL AND role IN (3, 4);

            /* change superadmins back to regular admins */
            UPDATE #{subdomain}.users
            SET role = 1
            WHERE role = 4;

            /* update users college_ids to the public college ids */
            UPDATE shared.users SET college_id = joined_ids.old_id
            FROM (SELECT shared.colleges.id AS new_id, public.colleges.id AS old_id
                  FROM shared.colleges
                  INNER JOIN public.colleges
                  ON shared.colleges.subdomain = public.colleges.subdomain) AS joined_ids
            WHERE joined_ids.new_id = college_id;


            /* add users back to their college tenants */
            INSERT INTO #{subdomain}.users (#{user_attribute_for_rollback_list})
            SELECT #{user_attribute_for_rollback_list}
            FROM shared.users
            WHERE college_id = #{college['id']} AND role IN (0, 1, 2);

            /* update room_assignment references to user_id back to the user */
            /* in the individual college tenant */
            UPDATE #{subdomain}.room_assignments SET user_id = joined_ids.old_id
            FROM (SELECT shared.users.id AS new_id, #{subdomain}.users.id AS old_id
                  FROM shared.users
                  INNER JOIN #{subdomain}.users ON CASE WHEN shared.users.username IS NULL
                                                   THEN shared.users.email = #{subdomain}.users.email
                                                   ELSE shared.users.username = #{subdomain}.users.username
                                                   END) AS joined_ids
            WHERE joined_ids.new_id = user_id;

            /* update membership references to user_id back to the user */
            /* in the individual college tenant */
            UPDATE #{subdomain}.memberships SET user_id = joined_ids.old_id
            FROM (SELECT shared.users.id AS new_id, #{subdomain}.users.id AS old_id
                  FROM shared.users
                  INNER JOIN #{subdomain}.users ON CASE WHEN shared.users.username IS NULL
                                                   THEN shared.users.email = #{subdomain}.users.email
                                                   ELSE shared.users.username = #{subdomain}.users.username
                                                   END) AS joined_ids
            WHERE joined_ids.new_id = user_id;
            SQL
          end

          #clear all data in the old shared schema
          execute <<-SQL
          ALTER TABLE shared.users DISABLE TRIGGER ALL;
          ALTER TABLE shared.colleges DISABLE TRIGGER ALL;

          DELETE FROM shared.users;
          DELETE FROM shared.colleges;

          ALTER TABLE shared.users ENABLE TRIGGER ALL;
          ALTER TABLE shared.colleges ENABLE TRIGGER ALL;
          SQL
        end
      end
    end

    add_foreign_key :memberships, "shared.users", column: :user_id
    add_foreign_key :room_assignments, "shared.users", column: :user_id
    add_foreign_key :users, :colleges
  end

  private

  USER_ATTRIBUTES = %w[email encrypted_password reset_password_token reset_password_sent_at remember_created_at sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip created_at updated_at role first_name last_name draw_id intent username class_year old_draw_id tos_accepted college_id]

  def user_attribute_list
    USER_ATTRIBUTES.join(', ')
  end

  USER_ATTRIBUTES_FOR_ROLLBACK = USER_ATTRIBUTES - ['college_id']

  def user_attribute_for_rollback_list
    USER_ATTRIBUTES_FOR_ROLLBACK.join(', ')
  end

  COLLEGE_ATTRIBUTES = %w[name dean admin_email created_at updated_at floor_plan_url student_info_text subdomain]

  def college_attribute_list
    COLLEGE_ATTRIBUTES.join(', ')
  end
end
