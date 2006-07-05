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

  def test_percentile_empty
    scores = []

    percentiles = Ranker.scores_to_percentiles(scores)

    assert_equal(0, percentiles.length)
  end

  def test_percentile_one
    scores = [1]

    percentiles = Ranker.scores_to_percentiles(scores)

    assert_equal(1.0, percentiles[0])
  end

  def test_percentile_even_dist
    scores = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    percentiles = Ranker.scores_to_percentiles(scores)

    assert_equal(0.10, percentiles[0])
    assert_equal(0.20, percentiles[1])
    assert_equal(0.30, percentiles[2])
    assert_equal(0.40, percentiles[3])
    assert_equal(0.50, percentiles[4])
    assert_equal(0.60, percentiles[5])
    assert_equal(0.70, percentiles[6])
    assert_equal(0.80, percentiles[7])
    assert_equal(0.90, percentiles[8])
    assert_equal(1.0, percentiles[9])
  end

  def test_percentile_skewed_dist
    scores = [1, 2, 3, 4, 5, 6, 10, 10, 10, 10]

    percentiles = Ranker.scores_to_percentiles(scores)

    assert_equal(0.10, percentiles[0])
    assert_equal(0.20, percentiles[1])
    assert_equal(0.30, percentiles[2])
    assert_equal(0.40, percentiles[3])
    assert_equal(0.50, percentiles[4])
    assert_equal(0.60, percentiles[5])
    assert_equal(1.0, percentiles[6])
    assert_equal(1.0, percentiles[7])
    assert_equal(1.0, percentiles[8])
    assert_equal(1.0, percentiles[9])
  end
end

