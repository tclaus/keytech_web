class RemoveUsernameFromUser < ActiveRecord::Migration[5.1]
  def change
      remove_column :users, :keytech_usdername, :string
      remove_column :users, :username, :string
  end
end
