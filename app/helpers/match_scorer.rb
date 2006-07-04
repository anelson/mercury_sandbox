require File.dirname(__FILE__) + '/normalizer'

class MatchScorer
  # Scores the strength of the match of 'search' in 'title'.
  #
  # Note that all characters in 'search' must appear, in order, in 'title'.
  # If this condition does not hold, an exception is raised
  def MatchScorer.score(search, title)
    if search.length == 0 || title.length == 0
      raise(ArgumentError,
            "search and title arguments cannot have zero length",
            caller)
    end

    scores = [
      MatchScorer.first_letter_score(search, title),
      MatchScorer.area_of_title_matched_score(search, title),
      MatchScorer.letter_match_spread_score(search, title)
    ]

    return scores
  end

  def MatchScorer.first_letter_score(search, title)
    # Proximity of search letters to the start of words
    # The number of words in a title is the number of word separators in the title, plus one
    num_words = title.scan(WORD_SEPARATOR).size.to_f + 1

    # Build a regex that matches each of the search letters at the start of a word
    ws = Regexp.escape(WORD_SEPARATOR)
    working_title = ws + title

    num_leading_letters = 0.0
    idx = 0

    re = Regexp.new("#{ws}(.)")

    match = re.match(working_title)

    while match != nil do 
      if match[1] == search[idx,1]
        num_leading_letters += 1
        idx += 1
      end

      match = re.match(match.post_match)
    end

    # TODO: Maybe compute num_leading_letters / search.length, and use num_leading_letters / num_words as 
    # a tie-breaker
    return (num_leading_letters / num_words) * (num_leading_letters / search.length)
  end

  def MatchScorer.area_of_title_matched_score(search, title)
    # Compute the proportion of the total title length contained between the first
    # and last matching character
    return get_match_coverage_area(search, title) / title.length.to_f
  end

  def MatchScorer.letter_match_spread_score(search, title)
    # Compute the extent to which the matching search letters are spread about amid the title
    return search.length.to_f / get_match_coverage_area(search, title)
  end

  def MatchScorer.get_match_coverage_area(search, title)
    # Compute the length of the substring of 'title' which contains all of the chars in
    # 'search', in order of appearnce
    regex = ""

    search.scan(/./) do |char|
      regex << char << ".*?"
    end

    regex.chomp!(".*?")

    match = Regexp.new(regex).match(title)

    raise(ArgumentError, 
        "Not all chars in search term '#{search}' present in title '#{title}'", 
        caller) unless match != nil

    match[0].length.to_f
  end
end
