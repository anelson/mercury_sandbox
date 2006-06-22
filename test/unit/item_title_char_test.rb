require File.dirname(__FILE__) + '/../test_helper'

class ItemTitleCharTest < Test::Unit::TestCase

  def test_item_title_char_relationships
    tc1 = TitleChar.new(:character => 'c')
    tc2 = TitleChar.new(:character => 'e', :parent => tc1)

    item1 = Item.new(:title => "item 1", :path => "/")
    item2 = Item.new(:title => "item 2", :path => "/")
    item3 = Item.new(:title => "item 3", :path => "/")

    tc1.save
    tc2.save
    item1.save
    item2.save
    item3.save

    tc1.items << item1

    assert_equal(1, tc1.items.size)
    assert_equal(1, Item.find(item1.id).title_chars.size)
    
    tc1.items << item2

    assert_equal(2, tc1.items.size)
    assert_equal(1, Item.find(item2.id).title_chars.size)

    tc2.items << item2

    assert_equal(1, tc2.items.size)
    assert_equal(2, item2.title_chars.size)
    
    tc2.items << item3

    assert_equal(2, tc2.items.size)
    assert_equal(1, Item.find(item3.id).title_chars.size)

    assert_equal(2, tc1.items.size)
    assert_equal(2, tc2.items.size)
    assert_equal(1, item1.title_chars.size)
    assert_equal(2, item2.title_chars.size)
    assert_equal(1, item3.title_chars.size)
     
  end
end
