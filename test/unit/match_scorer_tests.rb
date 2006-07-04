
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/match_scorer'

class MatchScorerTestTest < Test::Unit::TestCase
  WS = WORD_SEPARATOR

  def test_empty_both
    begin
      assert_equal(0, MatchScorer.score("", "")[0])
      fail("Exception not raised when search term and title empty")
    rescue ArgumentError
      assert(true)
    end
  end

  def test_empty_title
    begin
      assert_equal(0, MatchScorer.score("test", "")[0])
      fail("Exception not raised when title empty")
    rescue ArgumentError
      assert true
    end
  end

  def test_empty_search
    begin
      assert_equal(0, MatchScorer.score("", "test")[0])
      fail("Exception not raised when search term empty")
    rescue ArgumentError
      assert true
    end
  end

  def test_all_start_words_match
    title = "fear#{WS}is#{WS}the#{WS}mind#{WS}killer"
    search = "fitmk"

    num_words = 5.0
    num_first_letters = num_words

    assert_equal(num_first_letters / num_words, 
                  MatchScorer.score(search, title)[0])
  end

  def test_no_start_words_match
    title = "fear#{WS}is#{WS}the#{WS}mind#{WS}killer"
    search = "eshii"

    num_words = 5.0

    assert_equal(0, 
                  MatchScorer.score(search, title)[0])
  end

  def test_some_start_words_match
    title = "fear#{WS}is#{WS}the#{WS}mind#{WS}killer"
    search = "fitil"

    num_words = 5.0
    num_first_letters = 3.0

    assert_equal(num_first_letters / num_words, 
                  MatchScorer.score(search, title)[0])
  end

  def test_ambiguous_word_start_match
    title = Normalizer.normalize("FoobarOofBad")
    search = "fob" # Could match 'FOoB' or 'FoobarOofBad'

    num_words = 3.0
    num_first_letters = 3.0

    assert_equal(num_first_letters / num_words, 
                  MatchScorer.score(search, title)[0])
  end

  def test_real_world
    title = Normalizer.normalize("dan_pdf_test")
    search = "test"

    assert_equal(1.0/3.0, MatchScorer.score(search, title)[0])
  end

  def test_min_area_covered
    title = "foobarbazboofoo"
    search = "f"

    assert_equal(search.length.to_f / title.length.to_f,
                 MatchScorer.score(search, title)[1])
  end

  def test_norm_area_covered
    title = "foobarbazboofoo"
    search = "foob"

    assert_equal(search.length.to_f / title.length.to_f,
                 MatchScorer.score(search, title)[1])
  end

  def test_complete_substring_match_spread
    title = "onlytesting1234"
    search = "test"

    assert_equal(1.0, 
                 MatchScorer.score(search, title)[2])
  end

  def test_partially_complete_substring_match_spread
    title = "onlytesting1234"
    search = "ont"

    assert_equal(3.0/5.0, 
                 MatchScorer.score(search, title)[2])
  end

  def test_incomplete_substring_match_spread
    title = "onlytesting1234"
    search = "o4"

    assert_equal(2.0/title.length.to_f, 
                 MatchScorer.score(search, title)[2])
  end
end

