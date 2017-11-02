# frozen_string_literal: true

# Helper module for Mailers
module MailHelper
  # Return an HTML link to a given college's site url
  #
  # @param college [College] the college to return a link to
  # @return [String] an HTML link to the college's site url
  def college_site_link(college)
    link_to root_url(host: college.host), root_url(host: college.host)
  end

  # Return an HTML link to mail a given college's admin e-mail
  #
  # @param college [College] the college to return a link for
  # @return [String] an HTML link to mail the college's admin e-mail
  def admin_mail_link(college)
    link_to college.admin_email, "mailto:#{college.admin_email}"
  end
end
