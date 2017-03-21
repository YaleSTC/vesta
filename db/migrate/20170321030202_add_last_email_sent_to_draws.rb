class AddLastEmailSentToDraws < ActiveRecord::Migration[5.0]
  def change
    add_column :draws, :last_email_sent, :datetime
    add_column :draws, :email_type, :integer
  end
end
