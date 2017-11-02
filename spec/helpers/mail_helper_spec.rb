# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MailHelper, type: :helper do
  describe '#college_site_link' do
    it 'returns an html link to a college site url' do
      college = instance_spy('college', host: 'foo.example.com')
      result = helper.college_site_link(college)
      expect(result).to \
        eq('<a href="http://foo.example.com/">http://foo.example.com/</a>')
    end
  end

  describe '#admin_mail_link' do
    it "returns an html link to e-mail a college's admin e-mail" do
      college = instance_spy('college', admin_email: 'foo@example.com')
      result = helper.admin_mail_link(college)
      expect(result).to \
        eq('<a href="mailto:foo@example.com">foo@example.com</a>')
    end
  end
end
