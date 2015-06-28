#!/bin/env ruby

require 'list'
require 'sssla/pos'
require 'sssla/inflect'
require 'wary'

$KCODE = 'EUC'

$POS_S = '品詞'
$WORD_S = '見出し語'
$READING_S = '読み'
$PRON_S = '発音'
$ITYPE_S = '活用型'
$IFORM_S = '活用形'
$BASE_S = '原形'
$INFO_S = '付加情報'

class Morph_info
  attr_accessor :pos_id, :cost, :con_tbl
  attr_accessor :lex, :reading, :pron
  attr_accessor :itype, :iform
  attr_accessor :base, :info
  attr_accessor :dat_index

  def initialize
    @reading = @pron = @base = @info = ''
  end
end

def read_dic(list)
  pos, data = list
  if pos[0] != $POS_S then
    raise 'unexpected format'
  end

  morph = Morph_info.new
  pos = pos[1]
  morph.pos_id = $pos_tbl.get_pos_id(pos.join('-'))

  parse_data(morph, data)
end

def parse_data(morph, data)
  data.each do |tag, data|
    case tag
    when $WORD_S
      morph.lex, morph.cost = data
    when $READING_S
      morph.reading = data
    when $PRON_S
      morph.pron = data
    when $ITYPE_S
      morph.itype = $inflect.get_type_id(data)
    when $IFORM_S
      morph.iform = data
    when $INFO_S
      morph.info = info
    when $BASE_S
      morph.base = data
    else
      raise 'unexpected format'
    end
  end
  if !morph.itype.nil? and morph.iform.nil? then
    set_inflect(morph)
  end
  morph
end

def set_inflect(morph)
  bform = $inflect.get_basic_form_id(morph.itype)
  ending = $inflect.get_basic_ending(morph.itype)
  r_ending = $inflect.get_r_ending(morph.itype, bform)
  p_ending = $inflect.get_p_ending(morph.itype, bform)

  morph.lex.gsub!(Regexp.new("#{ending}$(?#)"), '')
  morph.reading.gsub!(Regexp.new("#{r_ending}$(?#)"), '')
  morph.pron.gsub!(Regexp.new("#{p_ending}$(?#)"), '')
  morph
end

def write_data(morph, dat_file)
  dat_index = dat_file.pos
  dat_file.write([morph.reading.size, morph.pron.size,
		   morph.base.size, morph.info.size].pack('CCCC'))
  dat_file.write("#{morph.reading}#{morph.pron}#{morph.base}#{morph.info}")
  dat_index
end


$pos_tbl = Sssla::POSTable.new('pos.sss')
$inflect = Sssla::Inflection.new('inf.sss')

entries = Hash.new

basename = ARGV.shift
dat_file = open(basename + '.dat', 'w')

builder = ListBuilder.new
ARGF.each do |line|
  next unless builder.parse(line)
  morph = read_dic(builder.get_list)
  builder.clear
  morph.dat_index = write_data(morph, dat_file)
  if entries[morph.lex].nil? then
    entries[morph.lex] = []
  end
  entries[morph.lex].push(morph)
end

lex_file = open(basename + '.lex', 'w')
entries.keys.sort.each do |word|
  morphs = entries[word]
  entries[word] = lex_file.pos
  lex_file.putc(morphs.size)
  morphs.each do |m|
    entry = [m.pos_id, m.itype, m.iform,
      m.cost, m.con_tbl, m.dat_index].pack('nCCnnN')
    lex_file.write(entry)
  end
end

Wary.new(entries).dump(basename + '.wry')
