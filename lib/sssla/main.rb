#  Sssla - morphological analizer
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
# $Id: main.rb,v 1.3 2002/01/05 05:49:59 kazuma-t Exp $

require 'sssla/pos'
require 'sssla/dic'
require 'sssla/graph'
require 'sssla/parse'
require 'sssla/unknown'
require 'sssla/version'

class Sssla
  def initialize(dic_dir)
    pos_file = File::join(dic_dir, 'pos.sss')
    inf_file = File::join(dic_dir, 'inf.sss')
    tbl_file = File::join(dic_dir, 'table.sss')
    mtx_file = File::join(dic_dir, 'matrix.sss')
    lex_file = File::join(dic_dir, 'chadic.lex')
    wry_file = File::join(dic_dir, 'chadic.wry')
    dat_file = File::join(dic_dir, 'chadic.dat')

    @pos_tbl = Sssla::POSTable.new(pos_file)
    @inflect = Sssla::Inflection.new(inf_file)
    @matrix = Sssla::ConnectMatrix.new(tbl_file, mtx_file)

    @unknown = Sssla::Unknown.new(@pos_tbl, @matrix)
    @dic = Sssla::Dictionary.new(@pos_tbl, @inflect,
				 lex_file, wry_file, @unknown)
    @dat = Mmap.new(dat_file)

    Sssla::Morph.set_param(@pos_tbl, @inflect, @dat)

    @parser = Sssla::Parser.new(@pos_tbl, @inflect, @dic, @matrix, @unknown)
  end

  def parse(sentence)
    @parser.parse(sentence)
  end
end
