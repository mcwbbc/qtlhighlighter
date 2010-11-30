class CreateQtls < ActiveRecord::Migration
  def self.up
    create_table :qtls do |t|
      t.string :symbol
    end
    add_index :qtls, :symbol, :unique => true
  end

  def self.down
    drop_table :qtls
  end
end
