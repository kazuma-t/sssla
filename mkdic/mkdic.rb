#!/usr/bin/env ruby
#
#  mkdic.rb - dictionary file converter from ChaSen to Sssla
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
# $Id: mkdic.rb,v 1.5 2001/12/12 03:23:56 kazuma-t Exp $

require 'wary'

CHAINT_OFFSET = 11
CHAINT_SCALE  = (256 - 11)

def unpack_int(c0, c1)
  (c0 - CHAINT_OFFSET) * CHAINT_SCALE + c1 - CHAINT_OFFSET
end

def conv_entry(entry, dat_file)
  form, reading, pron, base, info, param =
    entry.chomp.split("\0")
  pid0, pid1, inf_type, inf_form, w0, w1, ct0, ct1 =
    param[0..7].unpack('CCCCCCCC')
  pos_id = unpack_int(pid0, pid1)
  inf_type -= CHAINT_OFFSET
  inf_form -= CHAINT_OFFSET
  weight = unpack_int(w0, w1)
  con_tbl = unpack_int(ct0, ct1)
  dat_index = dat_file.pos
  dat_file.write([reading.size, pron.size, base.size, info.size].pack('CCCC'))
  dat_file.write("#{reading}#{pron}#{base}#{info}")
  [form,
    [pos_id, inf_type, inf_form, weight, con_tbl, dat_index].pack('nCCnnN')]
end

if ARGV.size != 2 or ARGV[0] =~ /^--/ then
  puts <<EOS
Usage: mkdir.rb CHADICDIR DICNAME
EOS
  exit
end

entries = Hash.new

input = open(ARGV[0] + '/chadic.int')
dat_file = open(ARGV[1] + '.dat', 'w')
input.each do |line|
  word, lex_data = conv_entry(line, dat_file)
  if entries[word].nil? then
    entries[word] = []
  end
  entries[word].push(lex_data)
end

lex_file = open(ARGV[1] + '.lex', 'w')
entries.keys.sort.each do |word|
  lexs = entries[word]
  entries[word] = lex_file.pos
  lex_file.putc(lexs.size)
  lexs.each {|l| lex_file.write(l)}
end

Wary.new(entries).dump(ARGV[1] + '.wry')
