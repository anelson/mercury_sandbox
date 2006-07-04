require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/normalizer'

class NormalizerTest < Test::Unit::TestCase
  WS = WORD_SEPARATOR

  KNOWN_ANSWER_TESTS = {
    "" => "",
    "   " => "",
    "lword" => "lword",
    "UWORD" => "uword",
    "two words" => "two#{WS}words",
    "CamelCaseWords" => "camel#{WS}case#{WS}words",
    "CamelCaseWords" => "camel#{WS}case#{WS}words",
    "null\1value" => "null#{WS}value",
    "punc+as!sep_char" => "punc#{WS}as#{WS}sep#{WS}char",
    "  leading space  " => "leading#{WS}space",
    "alpha2nonalpha" => "alpha#{WS}2#{WS}nonalpha",
    "dan_pdf_test" => "dan#{WS}pdf#{WS}test"
  }

  def test_known_answers
    KNOWN_ANSWER_TESTS.each_key do |input|
      output = KNOWN_ANSWER_TESTS[input]

      assert_equal(output, Normalizer.normalize(input))
    end
  end
end

