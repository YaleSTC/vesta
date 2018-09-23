# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupCreator do
  context 'size validations' do
    let(:draw) { instance_double(Draw) }

    it 'fails when it size is not available in the draw' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      allow(Draw).to receive(:find).and_return(draw)
      allow(draw).to receive(:open_suite_sizes).and_return([50])
      expect(described_class.create(params: params)[:msg]).to have_key(:error)
    end
    it 'succeeds when size is available in the draw' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      allow(Draw).to receive(:find).and_return(draw)
      allow(draw).to receive(:open_suite_sizes)\
        .and_return([params_hash[:size]])
      expect(described_class.create(params: params)[:msg]).to have_key(:success)
    end
  end

  context 'success' do
    it 'sucessfully creates a group' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.create(params: params)[:group]).to \
        be_instance_of(Group)
    end
    it 'returns a success flash message' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      expect(described_class.create(params: params)[:msg]).to have_key(:success)
    end
    it 'sets :redirect_object to the draw and the new group' do
      params = instance_spy('ActionController::Parameters', to_h: params_hash)
      result = described_class.create(params: params)[:redirect_object]
      expect(result.map(&:class)).to eq([Draw, Group])
    end
    it 'ignores the :remove_ids parameter' do
      params = instance_spy('ActionController::Parameters',
                            to_h: params_hash.merge('remove_ids' => ['1']))
      expect(described_class.create(params: params)[:redirect_object]).to \
        be_truthy
    end
  end

  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.create(params: params)[:redirect_object]).to be_nil
  end

  it 'returns the group even if invalid' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.create(params: params)[:record]).to \
      be_instance_of(Group)
  end

  # rubocop:disable RSpec/InstanceVariable
  def params_hash
    @leader ||= create(:student_in_draw)
    { size: @leader.draw.suite_sizes.first, leader_id: @leader.id }
  end
  # rubocop:enable RSpec/InstanceVariable
end
