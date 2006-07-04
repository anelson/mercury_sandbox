require File.dirname(__FILE__) + '/ranker'

class ScoreAggregator
  def ScoreAggregator.order_by_aggregate_rank(rank_sets)
    if rank_sets.length == 0
      return []
    end

    # Ensure every array within rank_sets has the same length
    num_positions = rank_sets.length
    num_scores = rank_sets[0].length

    rank_sets.each do |ranks|
      if ranks.length != num_scores
        raise(ArgumentError,
              "All arrays within 'rank_sets' must have the same length",
              caller)
      end
    end

    total_points = []
    (0..num_positions-1).step do |idx|
      # Sum the ranks assigned this item across all the rank sets
      total_points[idx] = rank_sets[idx].inject(0) do |points, rank|
        points + (num_positions - rank + 1)
      end
    end

    Ranker.rank_by_score(total_points)
  end

  # Given a multi-dimensional array of scores, ranks each dimension of scores first, 
  # then computes an aggregate score as order_by_aggregate_rank
  def ScoreAggregator.rank_and_order_by_aggregate_score(score_sets)
    rank_sets = []

    score_sets.transpose.each do |scores|
      rank_sets << Ranker.rank_by_score(scores)
    end

    ScoreAggregator.order_by_aggregate_rank(rank_sets.transpose)
  end
end
