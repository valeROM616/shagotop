class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.integer :user_id
      t.integer :steps
      t.integer :length

      t.timestamps
    end
  end
end
