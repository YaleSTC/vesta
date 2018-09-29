# frozen_string_literal: true

namespace :sid do
  desc 'Add SID to existing users in database'
  task add: :environment do
    # iterate through users
    User.all.each do |user|
      # call querier to get SID
      querier = IDRProfileQuerier.new(id: user.login_attr.to_s)
      attr_hash = querier.query
      # if SID, update user sid field
      if attr_hash.key?(:student_sid)
        user.update(student_sid: attr_hash[:student_sid])
      end
    end
  end
end
