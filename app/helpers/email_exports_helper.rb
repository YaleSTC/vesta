# frozen_string_literal: true

# Helper methods for email exports
module EmailExportsHelper
  # Return draw scoping header string
  def draw_scope_str(email_export)
    return 'All groups' unless email_export.draw_scoped?
    return 'Special groups' if email_export.draw_id.nil?
    "Draw: #{Draw.find(email_export.draw_id).name}"
  end

  # Return size scoping header string
  def size_scope_str(email_export)
    return '' unless email_export.size
    ", size: #{email_export.size}"
  end

  # Return locked scoping string
  def flag_scope_str(email_export)
    return ' (leaders of locked groups)' if email_export.locked &&
                                            email_export.leaders_only
    return ' (group leaders only)' if email_export.leaders_only
    return ' (locked only)' if email_export.locked
    ''
  end
end
