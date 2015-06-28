#!/usr/bin/env ruby
#
#  convmatrix.rb - automaton file converter from ChaSen to Sssla
# 
#  Copyright (C) 2001 TAKAOKA Kazuma. All rights reserved.
# 
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.
#  3. The name of the author may not be used to endorse or promote
#     products derived from this software without specific prior
#     written permission.
# 
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
#  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Id: convmatrix.rb,v 1.3 2001/12/12 03:23:56 kazuma-t Exp $

require 'sssla/connect'
require 'strscan'

def dump_table(input, output)
  table = Array.new
  entry_num = input.gets.chomp.to_i
  for index in 0..(entry_num - 1) do
    input.gets
    i_pos, j_pos, pos, form, type, lex = input.gets.split(" ")
    pair = Sssla::ConnectPair.new
    pair.index = index
    pair.i_pos = i_pos.to_i
    pair.j_pos = j_pos.to_i
    pair.pos = pos.to_i
    pair.form = form.to_i
    pair.type = type.to_i
    if lex == '*'
      pair.lex = ''
    else
      pair.lex = lex
    end
    table.push(pair)
  end
  Marshal.dump(table, output)
end

def dump_matrix(input, output)
  column_max, row_max =
    input.gets.chomp.split(" ").collect {|s| s.to_i}
  matrix = Array.new
  for i in 0..(column_max - 1) do
    matrix[i] = column = Array.new
    line = StringScanner.new(input.gets)
    j = 0
    while j < row_max do
      line.skip /\A\s+/
      nval = 0
      if line.scan(/\Ao/)
	nval = line.scan(/\A-?\d+/).to_i
	next_state = cost = 0
      else 
	next_state = line.scan(/\A-?\d+/).to_i
	line.scan(/\A,/)
	cost = line.scan(/\A-?\d+/).to_i
	if line.scan(/\Ax/)
	  nval = line.scan(/\A-?\d+/).to_i
	else
	  nval = 1
	end
      end
      nval.times do
	column[j] = cell = Sssla::ConnectRule.new
	cell.next = next_state
	cell.cost = cost
	j += 1
      end
    end
  end
  Marshal.dump(matrix, output)
end

if ARGV[0].nil? or ARGV[0] =~ /^--/ then
  puts <<EOS
Usage: convmatrix.rb CHADICDIR TABLEFILE MATRIXFILE
EOS
  exit
end

dump_table(open(ARGV[0] + '/table.cha'), open(ARGV[1], 'w'))
dump_matrix(open(ARGV[0] + '/matrix.cha'), open(ARGV[2], 'w'))
