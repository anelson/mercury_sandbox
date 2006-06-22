require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  fixtures :items

  def test_required_fields
    item = Item.new

    assert !item.valid?
    assert item.errors.invalid?(:title)
    assert item.errors.invalid?(:path)
    assert !item.errors.invalid?(:children)
    assert !item.errors.invalid?(:parent)

    item.title = "test"

    assert !item.valid?
    assert !item.errors.invalid?(:title)
    assert item.errors.invalid?(:path)

    item.path = "foo bar baz"

    assert item.valid?    
  end

  def test_new_item_relationships
    parent = Item.new(:title => "parent item", :path => "/")

    assert parent.children.size == 0

    child1 = Item.new(:title => "child 1", :path => "/c1", :parent => parent)

    assert parent.children.size == 0

    parent.children << child1
    
    assert parent.children.size == 1
    assert parent.children[0] == child1
    
    child2 = Item.new(:title => "child 2", :path => "/c2")
    child2.parent = parent
    parent.children << child2

    assert parent.children.size == 2
    assert parent.children[1] == child2
  end

  def test_childless_item_relationships
    item = items(:childless)

    assert item.children.size == 0
  end

  def test_parent_item_relationships
    parent = items(:parent)

    assert parent.children.size == 2

    assert parent.children.find(items(:child1).id) == items(:child1)
    assert parent.children.find(items(:child2).id) == items(:child2)
  end
end

