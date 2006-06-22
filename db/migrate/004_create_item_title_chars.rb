class CreateItemTitleChars < ActiveRecord::Migration
  def self.up
    create_table :items_title_chars, :id => false do |t|
       t.column :item_id, :integer, :null => false
       t.column :title_char_id, :integer, :null => false
    end

    #NB: title_char_id must come first for performance reasons
    add_index :items_title_chars, [:title_char_id, :item_id] #, :unique => true
  end

  def self.down
    drop_table :items_title_chars
  end
end
