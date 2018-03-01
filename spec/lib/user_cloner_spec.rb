# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserCloner do
  describe '#clone' do
    before do
      create_colleges_and_users
    end
    let(:io) { StringIO.new }
    let(:colleges) { College.all.order(:created_at) }
    # subdomain comes from spec/rails_helper.rb (setup)

    let(:first_user_email) { 'college@example.com' }

    context 'success' do
      it 'clones a user from one college to another' do
        described_class.clone(username: 'second@example.com',
                              from: colleges[1], to: colleges[2], io: io)
        expect(college_has_user?(college: colleges[2], attr: :email,
                                 value: 'second@example.com')).to be_truthy
      end
      it 'clones from the first college by default' do
        described_class.clone(username: first_user_email, to: colleges[2],
                              io: io)
        expect(college_has_user?(college: colleges[2], attr: :email,
                                 value: first_user_email)).to be_truthy
      end
      it 'clones to all other colleges by default' do
        described_class.clone(username: first_user_email, io: io)
        expectations = [colleges[1], colleges[2]].map do |c|
          college_has_user?(college: c, attr: :email, value: first_user_email)
        end
        expect(expectations.all?).to be_truthy
      end
      it 'appropriately uses the username when CAS is enabled' do
        allow(User).to receive(:cas_auth?).and_return(true)
        # subdomain comes from spec/rails_helper.rb (setup)
        described_class.clone(username: 'college', to: colleges[2], io: io)
        expect(college_has_user?(college: colleges[2], attr: :username,
                                 value: 'college')).to be_truthy
      end
    end

    context 'failure' do
      it 'handles a bad username' do # rubocop:disable RSpec/ExampleLength
        begin
          described_class.clone(username: first_user_email,
                                from: colleges[1], io: io)
        rescue SystemExit # since we need this to exit for the Rake task
          expect(io.string).to eq("Invalid username: #{first_user_email}\n")
        end
      end
      it 'handles the case when the user is a duplicate' do
        described_class.clone(username: first_user_email, from: colleges[0],
                              to: colleges[0], io: io)
        expect(io.string).to match(/Unable to clone.+user already exists/)
      end
    end
  end

  def create_colleges_and_users
    %w(second third).each { |sd| create(:college, subdomain: sd) }
    College.all.each do |c|
      c.activate!
      create(:user, username: c.subdomain, email: "#{c.subdomain}@example.com")
    end
  end

  def college_has_user?(college:, attr:, value:)
    college.activate!
    User.where(attr => value).count.positive?
  end
end
