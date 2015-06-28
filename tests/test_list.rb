$LOAD_PATH << '../mkdic'

require 'runit/testcase'
require 'runit/cui/testrunner'
require 'list'

class TestList < RUNIT::TestCase
  def setup
    @builder = ListBuilder.new
  end

  def test_simple_parse
    assert(@builder.parse('(abc)'))
    list = @builder.pop
    assert_equal(list[0], 'abc')
    assert_equal(list[1], nil)
    assert(@builder.parse('(cde fgh)'))
    assert(@builder.parse('(abc) (def)'))
    list = @builder.shift
    assert_equal(list[0], 'cde')
    assert_equal(list[1], 'fgh')
    assert_equal(list[2], nil)
    list = @builder.shift
    assert_equal(list[0], 'abc')
    list = @builder.shift
    assert_equal(list[0], 'def')
    assert(@builder.empty?)
  end

  def test_nested_parse
    assert(@builder.parse('(abc (cde))'))
    assert_equal(@builder[0][0], 'abc')
    assert_equal(@builder[0][1][0], 'cde')
    assert_equal(@builder[0][1][1], nil)
    assert_equal(@builder[0][2], nil)
  end

  def test_parse_fragments
    assert(!@builder.parse('(abc'))
    assert(@builder.parse(' cde)'))
    assert_equal(@builder[0][0], 'abc')
    assert_equal(@builder[0][1], 'cde')
  end
end

if $0 == __FILE__
  if ARGV.size == 0
    suite = TestList.suite
  else
    suite = RUNIT::TestSuite.new
    ARGV.each do |testmethod|
      suite.add_test(TestLIST.new(testmethod))
    end
  end
  RUNIT::CUI::TestRunner.run(suite)
end
