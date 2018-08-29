class AddKeytechUrlToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :keytech_url, :string
  end
end
