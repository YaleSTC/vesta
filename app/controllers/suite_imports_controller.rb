# frozen_string_literal: true

# Controller for Importing Suites
class SuiteImportsController < ApplicationController
  def import
    building = Building.find(suite_importer_params[:building_id])
    result = SuiteImportForm.import(building: building,
                                    file: suite_importer_params[:file].path)
    handle_action(path: building_path(building), **result)
  end

  private

  def authorize!
    authorize SuiteImportForm
  end

  def suite_importer_params
    params.require(:suite_import_form).permit(:file, :building_id).to_h
          .transform_keys(&:to_sym)
  end
end
