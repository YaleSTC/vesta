# frozen_string_literal: true

require 'rails_helper'

RSpec.describe College do
  describe 'validations' do
    subject { FactoryGirl.build(:college) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:admin_email) }
    it { is_expected.to validate_presence_of(:dean) }
    it { is_expected.to validate_uniqueness_of(:subdomain).case_insensitive }
  end

  describe 'subdomain callbacks' do
    it 'automatically sets a subdomain if missing based on name' do
      college = FactoryGirl.build(:college, name: 'foo', subdomain: nil)
      college.save!
      expect(college.subdomain).to eq('foo')
    end

    it 'downcases and escapes invalid characters' do
      college = FactoryGirl.build(:college, name: 'Foo Bar?', subdomain: nil)
      college.save!
      [' ', '?', 'B'].each { |c| expect(college.subdomain).not_to include(c) }
    end

    it 'does not overwrite existing values' do
      college = FactoryGirl.build(:college, subdomain: 'hello')
      college.save!
      expect(college.subdomain).to eq('hello')
    end

    it 'does not permit editing the subdomain' do
      college = FactoryGirl.create(:college, subdomain: 'foo')
      college.subdomain = 'bar'
      expect { college.save! }.to raise_error(ActiveRecord::RecordNotSaved)
    end
  end

  describe 'apartment callbacks' do
    it 'creates a schema on create' do
      allow(Apartment::Tenant).to receive(:create).with('foo')
      FactoryGirl.create(:college, subdomain: 'foo')
      expect(Apartment::Tenant).to have_received(:create).with('foo')
    end

    it 'drops the schema on destroy' do
      allow(Apartment::Tenant).to receive(:drop).with('foo')
      college = create(:college, subdomain: 'foo')
      college.destroy
      expect(Apartment::Tenant).to have_received(:drop).with('foo')
    end
  end

  describe '.current' do
    it 'returns the current college based on the apartment tenant' do
      allow(Apartment::Tenant).to receive(:current).and_return('foo')
      college = described_class.new
      allow(described_class).to receive(:find_by!).with(subdomain: 'foo')
                                                  .and_return(college)
      expect(described_class.current).to eq(college)
    end
  end

  describe '.activate!' do
    # rubocop:disable RSpec/ExampleLength
    it 'activates a given college by subdomain' do
      college = described_class.new
      allow(college).to receive(:activate!)
      allow(described_class).to receive(:find_by).with(subdomain: 'foo')
                                                 .and_return(college)
      described_class.activate!('foo')
      expect(college).to have_received(:activate!)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#activate!' do
    it "switches to the college's schema" do
      subdomain = 'foo'
      college = described_class.new(subdomain: subdomain)
      allow(Apartment::Tenant).to receive(:switch!).with(subdomain)
      college.activate!
      expect(Apartment::Tenant).to have_received(:switch!).with(subdomain)
    end
  end

  describe '#host' do
    it 'returns the host using to the subdomain of a given college' do
      allow(ENV).to receive(:[]).with('APPLICATION_HOST')
                                .and_return('example.com')
      college = described_class.new(subdomain: 'foo')
      expect(college.host).to eq('foo.example.com')
    end
  end
end
