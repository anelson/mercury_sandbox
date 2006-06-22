class CreateTitleChars < ActiveRecord::Migration
  def self.up
    create_table :title_chars do |t|
       t.column :character, :string, :null => false
       t.column :parent_title_char_id, :integer
    end

    # for performance reasons, the parent ID is first
    add_index :title_chars, [:parent_title_char_id, :character], :unique => true
  end

  def self.down
    drop_table :title_chars
  end
end

