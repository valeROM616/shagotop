class ChangeLengthToBeFloatInUsers < ActiveRecord::Migration[6.0]
  def change
	change_column :users, :length, :float
  end
end
