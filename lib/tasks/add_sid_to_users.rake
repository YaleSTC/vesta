# frozen_string_literal: true

namespace :sid do
  desc 'Add SID to existing users in database'
  task add: :environment do
    # iterate through users
    User.where(role: %w(student rep graduated)).each do |user|
      SidUpdaterJob.perform_later(user: user)
    end
  end
end
