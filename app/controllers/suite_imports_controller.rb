# frozen_string_literal: true

# Controller for Importing Suites
class SuiteImportsController < ApplicationController
  def create
    building = Building.find(suite_importer_params[:building_id])
    file = suite_importer_params[:file]
    file_path = file.path unless file.nil?
    result = SuiteImportForm.import(building: building,
                                    file: file_path)
    handle_action(path: building_path(building), **result)
  end

  private

  def authorize!
    authorize SuiteImportForm
  end

  def suite_importer_params
    params.require(:suite_import_form).permit(:file, :building_id).to_h
          .symbolize_keys
  end
end
