class RemoveOrphanDrawMemberships < ActiveRecord::Migration[5.1]
  def up
    # Remove inactive draw_membership records that are associated with active
    # draws.
    execute <<-SQL
      DELETE FROM draw_memberships
      USING  draws
      WHERE  draw_id = draws.id
             AND draw_memberships.active = FALSE
             AND draws.active = TRUE
    SQL

    # Remove draw_membership records that are not associated with a membership
    # OR a draw.
    # execute <<-SQL
    #   DELETE FROM draw_memberships
    #   USING  memberships
    #   WHERE  draw_memberships.id != memberships.draw_membership_id
    #          AND draw_memberships.draw_id IS NULL
    # SQL

    def down
      raise ActiveRecord::IrreversibleMigration
    end
  end
end
