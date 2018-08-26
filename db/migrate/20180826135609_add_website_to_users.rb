class AddWebsiteToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :keytech_website, :string
    add_column :users, :keytech_usdername, :string
    add_column :users, :keytech_password, :string
  end
end
