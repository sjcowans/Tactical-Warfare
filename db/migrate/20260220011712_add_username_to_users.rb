class AddUsernameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string, null: false
    add_index :users, :username, unique: true

    # allow email to be null
    change_column_null :users, :email, true
  end
end
