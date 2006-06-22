require File.dirname(__FILE__) + '/../test_helper'

class TitleCharTest < Test::Unit::TestCase
  fixtures :title_chars

  def test_required_fields
    char = TitleChar.new

    assert !char.valid?
    assert char.errors.invalid?(:character)
    assert !char.errors.invalid?(:children)
    assert !char.errors.invalid?(:parent)

    char.character ="t"

    assert char.valid?    
  end

  def test_new_char_relationships
    parent = TitleChar.new(:character => "f")

    assert parent.children.size == 0

    child1 = TitleChar.new(:character => "o")

    assert parent.children.size == 0

    parent.children << child1
    
    assert parent.children.size == 1
    assert parent.children[0] == child1
    
    child2 = TitleChar.new(:character => "s")
    child2.parent = parent
    parent.children << child2

    assert parent.children.size == 2
    assert parent.children[1] == child2
  end

  def test_childless_char_relationships
    char = title_chars(:childless)

    assert char.children.size == 0
  end

  def test_parent_char_relationships
    parent = title_chars(:parent)

    assert parent.children.size == 2

    assert parent.children.find(title_chars(:child1).id) == title_chars(:child1)
    assert parent.children.find(title_chars(:child2).id) == title_chars(:child2)
  end
end
