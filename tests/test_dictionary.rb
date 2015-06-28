require 'runit/testcase'
require 'runit/cui/testrunner'
require 'mmap'
require 'sssla/main'

$SSSLA_DIC_DIR = '../mkdic'
$inf_file = File::join($SSSLA_DIC_DIR, 'inf.sss')
$pos_file = File::join($SSSLA_DIC_DIR, 'pos.sss')
$tbl_file = File::join($SSSLA_DIC_DIR, 'table.sss')
$mtx_file = File::join($SSSLA_DIC_DIR, 'matrix.sss')
$lex_file = File::join($SSSLA_DIC_DIR, 'chadic.lex')
$wry_file = File::join($SSSLA_DIC_DIR, 'chadic.wry')
$dat_file = File::join($SSSLA_DIC_DIR, 'chadic.dat')

class TestSssla_Dictionary < RUNIT::TestCase
  def test_lookup
    inflect = Sssla::Inflection.new($inf_file)
    pos_tbl = Sssla::POSTable.new($pos_file)
    matrix = Sssla::ConnectMatrix.new($tbl_file, $mtx_file)
    unknown = Sssla::Unknown.new(pos_tbl, matrix)
    dic = Sssla::Dictionary.new(pos_tbl, inflect,
				$lex_file, $wry_file, unknown)
    dat = Mmap.new($dat_file)
    Sssla::Morph.set_param(pos_tbl, inflect, dat)
    assert_equal(dic.lookup("¡£", 0)[0].lex, "¡£")
    assert_equal(dic.lookup("Áö¤ì", 0)[0].lex, "Áö¤ì")
    assert_equal(dic.lookup("Áö¤ì", 0)[0].basic_form, "Áö¤ë")
    assert_equal(dic.lookup("Áö¤ì", 0)[1].lex, "Áö¤ì")
    assert_equal(dic.lookup("Áö¤ì", 0)[1].con_tbl, 1516)
    assert_equal(dic.lookup("ÄË¤¬¤ë", 0)[0].lex, "ÄË")
    assert_equal(dic.lookup("·ò¹¯", 0)[2].lex, "·ò¹¯")
  end
end

if $0 == __FILE__
  if ARGV.size == 0
    suite = TestSssla_Dictionary.suite
  else
    suite = RUNIT::TestSuite.new
    ARGV.each do |testmethod|
      suite.add_test(TestSssla_Dictionary.new(testmethod))
    end
  end
  RUNIT::CUI::TestRunner.run(suite)
end
