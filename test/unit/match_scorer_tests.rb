
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/match_scorer'

class MatchScorerTestTest < Test::Unit::TestCase
  WS = WORD_SEPARATOR

  def test_empty_both
    begin
      assert_equal(0, MatchScorer.score("", ""))
      fail("Exception not raised when search term and title empty")
    rescue ArgumentError
      assert(true)
    end
  end

  def test_empty_title
    begin
      assert_equal(0, MatchScorer.score("test", ""))
      fail("Exception not raised when title empty")
    rescue ArgumentError
      assert true
    end
  end

  def test_empty_search
    begin
      assert_equal(0, MatchScorer.score("", "test"))
      fail("Exception not raised when search term empty")
    rescue ArgumentError
      assert true
    end
  end

  def test_find_rightmost_char_positions
    title = "abcdefgfoobarbaz"
    search = "afaz"

    search_positions = MatchScorer.find_rightmost_char_positions(search, title)

    assert_equal(title.length - 1, search_positions[3])
    assert_equal(title.length - 2, search_positions[2])
    assert_equal(title.length - 9, search_positions[1])
    assert_equal(0, search_positions[0])
  end

  def test_find_word_starts
    title = Normalizer.normalize("fear is the mind killer")

    word_start_positions, word_start_characters = MatchScorer.find_word_starts(title)

    assert_equal(5, word_start_positions.length)
    assert_equal(5, word_start_characters.length)

    assert_equal("f", word_start_characters[0])
    assert_equal(word_start_characters[0], title[word_start_positions[0],1])

    assert_equal("i", word_start_characters[1])
    assert_equal(word_start_characters[1], title[word_start_positions[1],1])

    assert_equal("t", word_start_characters[2])
    assert_equal(word_start_characters[2], title[word_start_positions[2],1])

    assert_equal("m", word_start_characters[3])
    assert_equal(word_start_characters[3], title[word_start_positions[3],1])

    assert_equal("k", word_start_characters[4])
    assert_equal(word_start_characters[4], title[word_start_positions[4],1])
  end

  def test_mark_word_boundaries
    title = Normalizer.normalize("fear is the mind killer")
    search = "fmik"

    search_positions = MatchScorer.find_rightmost_char_positions(search, title)
    search_char_flags = Array.new(search_positions.length)

    search_char_flags.each_with_index do |dontcare, idx|
      search_char_flags[idx] = 0
    end

    MatchScorer.mark_word_boundaries(search, title, search_positions, search_char_flags)

    assert_equal(MatchScorer::SCORE_WORD_BOUNDARY, search_char_flags[0])
    assert_equal(MatchScorer::SCORE_WORD_BOUNDARY, search_char_flags[1])
    assert_equal(0, search_char_flags[2])
    assert_equal(MatchScorer::SCORE_WORD_BOUNDARY, search_char_flags[3])
  end

  def test_all_start_words_match
    title = Normalizer.normalize("fear is the mind killer")
    search = "fitmk"

    assert_equal(1.0, 
                  MatchScorer.score(search, title))
  end

  def test_no_start_words_match
    title = Normalizer.normalize("fear is the mind killer")
    search = "eshii"

    assert_equal(0, 
                  MatchScorer.score(search, title))
  end

  def test_some_start_words_match
    title = "fear#{WS}is#{WS}the#{WS}mind#{WS}killer"
    search = "fitil"

    assert_equal(3.0/5.0, 
                MatchScorer.score(search, title))
  end

  def test_ambiguous_word_start_match
    title = Normalizer.normalize("FoobarOofBad")
    search = "fob" # Could match 'FOoB' or 'FoobarOofBad'

    assert_equal(1.0, 
                  MatchScorer.score(search, title))
  end

  def test_real_world
    title = Normalizer.normalize("dan_pdf_test")
    search = "test"

    assert_equal(1.0, MatchScorer.score(search, title))
  end

  def test_zero_score
    title = Normalizer.normalize("military//cheaperthandirt//com")
    search = "nic"

    assert_equal(0.0, MatchScorer.score(search, title))
  end

  def test_min_area_covered
    title = "foobarbazboofoo"
    search = "f"

    assert_equal(1.0,
                 MatchScorer.score(search, title))
  end

  def test_norm_area_covered
    title = "foobarbazboofoo"
    search = "foob"

    assert_equal(7.0/8.0,
                 MatchScorer.score(search, title))
  end

  def test_complete_substring_match_spread
    title = "onlytesting1234"
    search = "test"

    assert_equal(3.0/4.0, 
                 MatchScorer.score(search, title))
  end

  def test_partially_complete_substring_match_spread
    title = "onlytesting1234"
    search = "ont"

    assert_equal(1.5 / 3.0, 
                 MatchScorer.score(search, title))
  end

  def test_incomplete_substring_match_spread
    title = "onlytesting1234"
    search = "o4"

    assert_equal(0.5,
                 MatchScorer.score(search, title))
  end
end

