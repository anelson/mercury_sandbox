require File.dirname(__FILE__) + '/normalizer'

class MatchScorer
  SCORE_WORD_BOUNDARY = 0x01
  SCORE_PRECEEDING_CHAR = 0x02
  SCORE_SUCCEEDING_CHAR = 0x04
  SCORE_SURROUNDED_CHAR = (SCORE_PRECEEDING_CHAR | SCORE_SUCCEEDING_CHAR)

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

    search_positions, search_char_flags = MatchScorer.find_search_chars_in_title(search, title)

    return MatchScorer.simple_score(search_positions, search_char_flags)
  end

  def MatchScorer.find_search_chars_in_title(search, title)
    search_char_flags = Array.new(search.length)

    search_char_flags.each_with_index do |dontcare, idx|
      search_char_flags[idx] = 0
    end

    search_positions = MatchScorer.find_rightmost_char_positions(search, title)

    MatchScorer.mark_word_boundaries(search, title, search_positions, search_char_flags)

    # Leaving the position of the word boundary letters fixed, change the search positions
    # of the non-word-boundary characters to the left-most possible
    prev_pos = 0
    search_positions.each_with_index do |pos, idx|
      if ! (search_char_flags[idx] & SCORE_WORD_BOUNDARY == SCORE_WORD_BOUNDARY)
        search_positions[idx] = title.index(search[idx,1], prev_pos)
      end

      prev_pos = search_positions[idx] + 1
    end

    # Compute the non-word-boundary search char flags
    search_char_flags.each_with_index do |flags, idx|
      if (flags & SCORE_WORD_BOUNDARY == SCORE_WORD_BOUNDARY)
        next
      end

      # Preceeding char?
      if idx > 0 && search_positions[idx-1] == search_positions[idx] - 1
        #Yes
        search_char_flags[idx] |= SCORE_PRECEEDING_CHAR

        #If this is the last character in the title, it also gets the 
        #succeeding char flag
        if search_positions[idx] == title.length - 1
          search_char_flags[idx] |= SCORE_SUCCEEDING_CHAR
        end
      end

      # Succeeding char?
      if idx < search_positions.length - 1 && search_positions[idx+1] == search_positions[idx] + 1
        # Yes
        search_char_flags[idx] |= SCORE_SUCCEEDING_CHAR
      end
    end

    [search_positions, search_char_flags]
  end

  def MatchScorer.find_rightmost_char_positions(search, title)
    search_positions = Array.new(search.length)

    # Starting from the last search char and the end of the title and 
    # working backwards, find the right-most possible index for each char in the search
    prev_pos = -1
    (0..search.length-1).step(1) do |from_left_idx|
      idx = search.length - 1 - from_left_idx

      search_positions[idx] = title.rindex(search[idx,1], prev_pos)

      if search_positions[idx] == nil
        raise(ArgumentError,
              "The search character #{search[idx,1]} not found by '#{title}'.rindex('#{search[idx,1]}', #{prev_pos-1})",
              caller)
      end

      prev_pos = search_positions[idx] - 1
    end

    search_positions
  end

  def MatchScorer.mark_word_boundaries(search, title, search_positions, search_char_flags)
    # Check for search letters at the start of words, at positions equal to or earlier than
    # the right-most positions found above
    word_start_positions, word_start_characters = MatchScorer.find_word_starts(title)
    word_idx = 0

    search_positions.each_with_index do |val, idx|
      search_char = search[idx,1]

      #Does the character at this index start a word?
      temp_idx = word_start_characters[word_idx..-1].index(search_char)

      if temp_idx != nil && word_start_positions[temp_idx] <= val
        #A word starting with this character is present in the string on or before
        #the right-most occurence of this char.
        search_char_flags[idx] = SCORE_WORD_BOUNDARY
        word_idx = temp_idx+1

        if word_idx == word_start_characters.length
          #No more words
          break
        end
      else
        #No word starting with this character.  pick up the word-start search for subsequent
        #characters, after the nearest occurence of this character.  
        nearest_char_idx = title.index(search[idx,1], word_start_positions[word_idx])

        if nearest_char_idx == nil
          #This character isn't present past the current word, which means no further
          #characters will be either; abort the search
          break
        end

        #Find the first word start index AFTER this char
        word_idx = nil
        word_start_positions.each_with_index do |pos, wsp_idx|
          if pos > nearest_char_idx
            word_idx = wsp_idx
            break
          end
        end

        if word_idx == nil
          #No more word starts; that's the last of the search terms that align on
          #word boundaries
          break
        end
      end
    end
  end

  def MatchScorer.find_word_starts(title)
    word_start_positions = []
    word_start_characters = []

    match_offset = 0
    re = Regexp.new("#{Regexp.escape(WORD_SEPARATOR)}(.)")

    #the first match is the first letter in the title; subsequent matches are
    #letters following word separators
    match = /^(.)/.match(title)

    while match != nil do 
      # The position of this match, relative to the start of the title
      word_start_positions << match_offset + match.offset(1)[0]
      word_start_characters << match[1]

      # Add the ending offset of the entire string matched by the regex, to compute
      # the index relative to the start of the title to search next
      match_offset += match.offset(0)[1] 
      match = re.match(title[match_offset..-1])
    end

    return word_start_positions, word_start_characters
  end

  def MatchScorer.simple_score(search_positions, search_char_flags)
    max_per_char_score = 1.0/search_positions.length.to_f

    total_score = 0.0

    search_char_flags.each do |flags|
      if (flags & SCORE_WORD_BOUNDARY == SCORE_WORD_BOUNDARY) || 
         (flags & SCORE_SURROUNDED_CHAR == SCORE_SURROUNDED_CHAR)
        total_score += max_per_char_score
      elsif (flags & SCORE_PRECEEDING_CHAR == SCORE_PRECEEDING_CHAR) || 
            (flags & SCORE_SUCCEEDING_CHAR == SCORE_SUCCEEDING_CHAR)
        total_score += (max_per_char_score / 2.0)
      end
    end

    #Absurdly, Ruby's Float type can introduce rounding errors here, such that
    #floats that appear the same vary slightly.  As a horrifically kludgy workaround,
    #convert to string and back
    total_score.to_s.to_f

    #To reproduce this problem, score a title with five words, and a five-letter search term,
    #with three letters matching word boundaries and two letters matching nothing.
    #the score should be 3.0/5.0, but the following code will fail, reporting a tiny
    #(on the order of 1.0e-16) difference
    #
    #if total_score != (3.0/5.0) 
    #  puts total_score - (3.0/5.0) # Outputs something like 1.11022302462516e-016
    #  raise
    #end
  end
end
