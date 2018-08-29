class RemoveKeytchWebFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :keytech_website, :string
  end
end
