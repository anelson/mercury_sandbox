class Item < ActiveRecord::Base
  # todo: use acts_as_tree instead
  validates_presence_of :path, :title
  
  # An item may have zero or more child items
  has_many :children, 
           :class_name => "Item", 
           :foreign_key => "parent_item_id", 
           :dependent => true

  # An item has zero or one parent items
  belongs_to :parent,
             :class_name => "Item",
             :foreign_key => "parent_item_id"

  # An item has zero or more title chars
  has_and_belongs_to_many :title_chars
end

