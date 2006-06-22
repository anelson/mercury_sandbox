class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
        t.column :path, :string, :null => false
        t.column :title, :string, :null => false
        t.column :parent_item_id, :integer
    end
  end

  def self.down
    drop_table :items
  end
end
