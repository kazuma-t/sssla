require 'runit/testcase'
require 'runit/cui/testrunner'
require 'connect'

class TestConnectMatrix < RUNIT::TestCase
  def setup
    @matrix = Chasen::ConnectMatrix.new(open("table.sss"), open("matrix.sss"))
  end
  def test_check_automaton
    assert_equal(@matrix.check_automaton(0,0,0), [0, 391])
    assert_equal(@matrix.check_automaton(9,0,0), [0, 831])
  end
end

if $0 == __FILE__
  if ARGV.size == 0
    suite = TestConnectMatrix.suite
  else
    suite = RUNIT::TestSuite.new
    ARGV.each do |testmethod|
      suite.add_test(TestConnectMatrix.new(testmethod))
    end
  end
  RUNIT::CUI::TestRunner.run(suite)
end
