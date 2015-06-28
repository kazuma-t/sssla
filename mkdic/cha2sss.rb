#!/usr/bin/env ruby
#
#  cha2sss.rb - grammar data converter from ChaSen to Sssla
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
# $Id: cha2sss.rb,v 1.4 2001/12/12 03:23:56 kazuma-t Exp $

require 'list'
require 'sssla/inflect'
require 'sssla/pos'

def read_cha_pos(grammar_fname)
  bos = Sssla::POS.new
  bos.name.push('BOS/EOS')
  bos.fullname = 'BOS/EOS'
  bos.path.push(0)
  cha_pos_array = [bos]

  f = open(grammar_fname)
  pos_tree = ListBuilder.new.build(f)
  pos_tree.each do |cat|
    parse_POS_tree(cha_pos_array, cat)
  end

  cha_pos_array
end

def parse_POS_tree(cha_pos_array, tree, parent=Sssla::POS.new)
  pos = Sssla::POS.new
  name = tree.shift
  pos.name = parent.name.dup
  pos.path = parent.path.dup

  if name =~ /%$/ then
    name.chop!
    pos.is_inflect = true
  end
  if parent.is_inflect then
    pos.is_inflect = true
  end

  pos.name.push(name)
  pos.fullname = pos.name.join('-')
  pos.path.push(cha_pos_array.size)
  cha_pos_array.push(pos)

  tree.each do |node|
    if !node.empty? then
      parse_POS_tree(cha_pos_array, node, pos)
    end
  end
end


def read_cha_cforms(cforms_fname)
  f = open(cforms_fname)
  itype_list = [nil]
  ListBuilder.new.build(f).each do |entry|
    itype = Sssla::InfType.new
    itype.name = entry[0]
    itype.form.push(nil)
    itype_list.push(itype)
    entry[1].each do |form|
      form.collect! do |f|
	f == '*' ? '' : f
      end
      if form[2].nil? then
	form[2] = form[1]
      end
      if form[3].nil? then
	form[3] = form[2]
      end
      inf_form = Sssla::InfForm.new(form[0], form[1], form[2], form[3])
      itype.form.push(inf_form)
    end
    itype.basic = itype.form[1] # ???
  end
  itype_list
end

def dump_inflection(chadic_dir, output)
  inflect_list = read_cha_cforms(chadic_dir + '/cforms.cha')
  Marshal.dump(inflect_list, output)
end


def dump_POS(chadic_dir, output)
  pos_list = read_cha_pos(chadic_dir + '/grammar.cha')
  Marshal.dump(pos_list, output)
end

if ARGV.size != 3 or ARGV[0] =~ /^--/ then
  puts <<EOS
Usage: cha2sss.rb CHADICDIR POSFILE INFLECTFILE
EOS
  exit
end

dump_POS(ARGV[0], open(ARGV[1], 'w'))
dump_inflection(ARGV[0], open(ARGV[2], 'w'))
