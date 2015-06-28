#!/usr/local/bin/ruby -Ke

require 'pos'
require 'dic'

pos_tbl = Chasen::POSTable.new('pos.sss')
inflect = Chasen::Inflection.new('inf.sss')
dic = Chasen::Dictionary.new(inflect, 'chadic.lex', 'chadic.wry', nil)

if ARGV[0] != nil
  string = ARGV[0]
  
  offset = 0
  string.split("").collect{|c| c.length}.each {|clen|
    morphs = dic.lookup(string, offset)
    morphs.each {|m| print m.to_string(pos_tbl, inflect), "\n" }
    print "\n"
    offset += clen
  }
else
  print "usage: lookup-dic.rb <pattern>\n"
end
