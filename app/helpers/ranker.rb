
# Helper class which computes a rank for each item in an array of items, based on
# an item's score

class Ranker
  def Ranker.rank_by_score(scores)
    #Sort in descending order of score (higher score == higher position)
    if scores.length == 0
      return []
    end

    ordered_scores = [ Array.new(scores), []]
    (0..scores.length-1).step do |idx|
      ordered_scores[1] << idx
    end

    ordered_scores = ordered_scores.transpose
    ordered_scores.sort! do |x, y|
      y[0] <=> x[0]
    end

    # Convert the scores into a proper ordinal rank
    last_score = ordered_scores[0][0] + 1 # All scores are lower than this one
    next_rank = 0

    ordered_scores.each_with_index do |score, index|
      if score[0] < last_score
        next_rank += 1
        last_score = score[0]
      end

      ordered_scores[index][0] = next_rank
    end

    #Sort again by original ordinal, to restore the previous order
    ordered_scores.sort! do |x, y|
      x[1] <=> y[1]
    end

    ordered_scores.transpose[0]
  end

  def Ranker.scores_to_percentiles(scores)
    # Compute percentiles from the scores
    if scores.length == 0
      return []
    end

    ordered_scores = [ Array.new(scores), []]
    (0..scores.length-1).step do |idx|
      ordered_scores[1] << idx
    end

    ordered_scores = ordered_scores.transpose
    ordered_scores.sort! do |x, y|
      y[0] <=> x[0]
    end

    # For each score, compute the proportion of the total array containing 
    # scores greater than or equal to each score
    last_score = ordered_scores[0][0] # All scores are lower than this one
    percentile = 1.0

    ordered_scores.each_with_index do |score, index|
      if score[0] < last_score
        percentile = (ordered_scores.length - index) / ordered_scores.length.to_f
        last_score = score[0]
      end

      ordered_scores[index][0] = percentile
    end

    #Sort again by original ordinal, to restore the previous order
    ordered_scores.sort! do |x, y|
      x[1] <=> y[1]
    end

    ordered_scores.transpose[0]
  end
end
