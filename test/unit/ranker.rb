require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/ranker'

class RankerTest < Test::Unit::TestCase
  def test_order_empty_list
    ranks = Ranker.rank_by_score([])

    assert_equal(0, ranks.length)
  end

  def test_order_one_item_list
    ranks = Ranker.rank_by_score([1])

    assert_equal(1, ranks.length)
  end

  def test_order_multi_item_list
    scores = [
      1.0,
      0.0,
      0.5,
      0.4999
    ]

    ranks = Ranker.rank_by_score(scores)

    assert_equal(4, ranks.length)

    assert_equal(ranks[0], 1)
    assert_equal(ranks[1], 4)
    assert_equal(ranks[2], 2)
    assert_equal(ranks[3], 3)
  end

  def test_order_with_ties
    scores = [
      1.0,
      0.0,
      0.5,
      0.5
    ]

    ranks = Ranker.rank_by_score(scores)

    assert_equal(4, ranks.length)

    assert_equal(ranks[0], 1)
    assert_equal(ranks[1], 3)
    assert_equal(ranks[2], 2)
    assert_equal(ranks[3], 2)
  end
end

