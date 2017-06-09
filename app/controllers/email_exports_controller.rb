# frozen_string_literal: true

# Controller for email exports
class EmailExportsController < ApplicationController
  before_action :prepare_form_data

  def new
    @email_export = EmailExport.new
  end

  def create
    @email_export = EmailExport.new(email_export_params).generate
    if @email_export.valid?
      render 'show'
    else
      flash[:error] = 'Invalid export request'
      render 'new'
    end
  end

  private

  def authorize!
    authorize(EmailExport)
  end

  def email_export_params
    p = params.require(:email_export).permit(%i(draw_id size locked))
    p.reject { |_k, v| v.empty? }
  end

  def prepare_form_data
    @draws = Draw.all.order(:name).to_a
    @draws.insert(0, Draw.new(name: 'Special groups', id: 0))
    @sizes = GroupSizesQuery.call
  end
end
