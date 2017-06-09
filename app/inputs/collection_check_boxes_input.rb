# frozen_string_literal: true

#
# Overrides checkbox input to include inline styling
class CollectionCheckBoxesInput < SimpleForm::Inputs::CollectionCheckBoxesInput
  def item_wrapper_class
    'inline-checkbox'
  end
end
