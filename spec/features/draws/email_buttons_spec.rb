# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw email buttons' do
  before do
    FactoryGirl.create(:college)
    log_in(FactoryGirl.create(:admin))
  end

  context 'before intent deadline' do
    let(:draw) do
      FactoryGirl.create(:draw_with_members,
                         status: 'pre_lottery',
                         intent_deadline: Time.zone.tomorrow)
    end

    it 'sends intent reminders' do
      time = Time.zone.now.strftime('%B %e, %l:%M %P')
      visit draw_path(draw)
      click_on 'Send intent reminder'
      expect(page).to have_content(time)
    end
  end

  context 'after intent deadline and before lottery' do
    let!(:draw) do
      FactoryGirl.create(:draw_with_members,
                         status: 'pre_lottery',
                         intent_deadline: Time.zone.tomorrow,
                         locking_deadline: Time.zone.today + 3.days)
    end

    before { Timecop.freeze(Time.zone.now + 2.days) }
    after { Timecop.return }

    it 'sends locking reminders' do
      time = Time.zone.now.strftime('%B %e, %l:%M %P')
      visit draw_path(draw)
      click_on 'Send locking reminder'
      expect(page).to have_content(time)
    end
  end
end
