class CreateUserLists < ActiveRecord::Migration[6.0]
  def change
    create_table :user_lists do |t|
      t.integer :user_id
      t.integer :steps
      t.float :length
      t.string :firstname
      t.string :lastname
      t.boolean :flag
      t.timestamps
    end
  end
end
