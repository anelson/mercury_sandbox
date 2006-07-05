require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/score_aggregator'

class ScoreAggregatorTest < Test::Unit::TestCase
  def test_order_one_item
    ranks = ScoreAggregator.order_by_aggregate_rank([ [1] ])

    assert_equal(1, ranks.length)
    assert_equal(1, ranks[0])
  end

  def test_order_no_items
    ranks = ScoreAggregator.order_by_aggregate_rank([])

    assert_equal(0, ranks.length)
  end

  def test_order_no_scores
    ranks = ScoreAggregator.order_by_aggregate_rank([ [] ])

    assert_equal(1, ranks.length)
    assert_equal(1, ranks[0])
  end

  def test_order_single_source
    inputs = [
      [3],
      [1],
      [2]
    ]

    ranks = ScoreAggregator.order_by_aggregate_rank(inputs)

    assert_equal(3, ranks.length)
    assert_equal(3, ranks[0])
    assert_equal(1, ranks[1])
    assert_equal(2, ranks[2])
  end

  def test_order_two_source
    inputs = [
      [3, 2],# index 0
      [1, 1],# index 1
      [2, 3]
    ]

    ranks = ScoreAggregator.order_by_aggregate_rank(inputs)

    assert_equal(3, ranks.length)

    # either the 3 and 2 item (index 0) or the 2 and 3 item (index 2)
    # can be in second; they are tied.  The 1 and 1 item (index 1) is clearly
    # first
    assert_equal(2, ranks[0])
    assert_equal(1, ranks[1])
    assert_equal(2, ranks[2])
  end

  def test_order_by_score_no_items
    ranks = ScoreAggregator.rank_and_order_by_aggregate_score([ [] ])

    assert_equal(0, ranks.length)
  end

  def test_order_by_score_one_item
    ranks = ScoreAggregator.rank_and_order_by_aggregate_score([ [0.5] ])

    assert_equal(1, ranks.length)
    assert_equal(1, ranks[0])
  end

  def test_order_by_score_single_source
    inputs = [
      [0.9],
      [0.3],
      [0.6]
    ]

    ranks = ScoreAggregator.rank_and_order_by_aggregate_score(inputs)

    assert_equal(3, ranks.length)
    assert_equal(1, ranks[0])
    assert_equal(3, ranks[1])
    assert_equal(2, ranks[2])
  end

  def test_order_by_score_two_source
    inputs = [
      [30,20],# index 0
      [10,10],# index 1
      [20,30] # index 2
    ]

    ranks = ScoreAggregator.rank_and_order_by_aggregate_score(inputs)

    assert_equal(3, ranks.length)

    # either the 30 and 20 item (index 0) or the 20 and 30 item (index 2)
    # can be in first; they are tied.  The 10 and 10 item (index 1) is clearly
    # second
    assert_equal(1, ranks[0])
    assert_equal(2, ranks[1])
    assert_equal(1, ranks[2])
  end

  def test_order_by_percentile_score_two_source
    inputs = [
      [30,20],# index 0
      [10,10],# index 1
      [20,30] # index 2
    ]

    ranks = ScoreAggregator.rank_and_order_by_aggregate_score(inputs)

    assert_equal(3, ranks.length)

    # either the 30 and 20 item (index 0) or the 20 and 30 item (index 2)
    # can be in first; they are tied.  The 10 and 10 item (index 1) is clearly
    # second
    assert_equal(1, ranks[0])
    assert_equal(2, ranks[1])
    assert_equal(1, ranks[2])
  end
end

