class TitleChar < ActiveRecord::Base
  # todo: use acts_as_tree instead
    validates_presence_of :character
    
    # A title char may have zero or more child chars
    has_many :children, 
             :class_name => "TitleChar", 
             :foreign_key => "parent_title_char_id", 
             :dependent => true

    # An title char has zero or one parent title char
    belongs_to :parent,
               :class_name => "TitleChar",
               :foreign_key => "parent_title_char_id"

    # A title char has and belongs to many items
    has_and_belongs_to_many :items
end
