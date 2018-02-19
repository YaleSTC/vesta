# frozen_string_literal: true

def page_is_valid_export?(page:, data:, filename:, header_str:)
  headers = page.response_headers
  headers['Content-Disposition'] == "attachment; filename=\"#{filename}\"" &&
    headers['Content-Type'] == 'text/csv' &&
    page.body.include?(header_str) &&
    data.all? { |record| page.body.include?(export_row_for(record)) }
end

# This method must be defined in each context you want to use the
#   above helper method
def export_row_for(_record)
  raise NotImplementedError
end
