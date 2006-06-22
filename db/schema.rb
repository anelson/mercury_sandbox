# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 4) do

  create_table "items", :force => true do |t|
    t.column "path", :string, :null => false
    t.column "title", :string, :null => false
    t.column "parent_item_id", :integer
  end

  create_table "items_title_chars", :id => false, :force => true do |t|
    t.column "item_id", :integer, :null => false
    t.column "title_char_id", :integer, :null => false
  end

  add_index "items_title_chars", ["title_char_id", "item_id"], :name => "items_title_chars_title_char_id_index"

  create_table "title_char_ancestors", :id => false, :force => true do |t|
    t.column "title_char_id", :integer, :null => false
    t.column "title_char_character", :string, :limit => nil, :null => false
    t.column "ancestor_title_char_id", :integer
  end

  add_index "title_char_ancestors", ["title_char_id"], :name => "idx_title_char_ancestors_tci"

  create_table "title_chars", :force => true do |t|
    t.column "character", :string, :null => false
    t.column "parent_title_char_id", :integer
  end

  add_index "title_chars", ["parent_title_char_id", "character"], :name => "title_chars_parent_title_char_id_index", :unique => true

end