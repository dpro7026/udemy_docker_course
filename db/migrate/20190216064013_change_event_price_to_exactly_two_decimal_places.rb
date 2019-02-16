class ChangeEventPriceToExactlyTwoDecimalPlaces < ActiveRecord::Migration[5.2]
  # change_column :table_name, :column_name, :new_type
  def up
    change_column :events, :price, :decimal
  end

  def down
    change_column :events, :price, :decimal, scale: 2
  end
end


