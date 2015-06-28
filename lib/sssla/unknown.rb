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
# $Id: unknown.rb,v 1.3 2001/12/06 16:06:09 kazuma-t Exp $

require 'strscan'

$KCODE = 'EUC'

class Sssla
  class Unknown
    def initialize(pos_tbl, connect_matrix)
      @pos_tbl = pos_tbl
      @con_matrix = connect_matrix
      @num_reg = Regexp.new("^[£°-£¹¡»°ìÆó»°»Í¸ÞÏ»¼·È¬¶å½½É´ÀéËü²¯Ãû][¡¤¡¥£°-£¹¡»°ìÆó»°»Í¸ÞÏ»¼·È¬¶å½½É´ÀéËü²¯Ãû]*")
      @alpha_reg = Regexp.new("^[£Á-£ú¦¡-¦Ø§¡-§ñ]+")
      @hira_reg = Regexp.new("^[¤¡-¤ó][¤¡-¤ó¡µ¡¶]*")
      @kata_reg = Regexp.new("^[¥¡-¥ö][¥¡-¥ö¡¼¡³¡´]*")
      @kan_reg = Regexp.new("^[¡¸-¡»°¡-ô¦]+")
      @sym_reg = Regexp.new("^[¡¢-¢þ]+")
    end
    def set_graph(graph)
      @graph = graph
    end
    def estimate(string, length, cursor)
      form = string[0...length]
      return get_unknown(form)
    end

    private
    def char_type(str)
      scan = StringScanner.new(str)
      char_type = ''
      while !scan.empty? do
	if scan.scan(@num_reg) then
	  char_type += '¿ô'
	elsif scan.scan(@alpha_reg) then
	  char_type += '£Á'
	elsif scan.scan(@hira_reg) then
	  char_type += '¤Ò'
	elsif scan.scan(@kata_reg) then
	  char_type += '¥«'
	elsif scan.scan(@kan_reg) then
	  char_type += '´Á'
	elsif scan.scan(@sym_reg) then
	  char_type += 'µ­'
	elsif scan.scan(/\A./) then
	  char_type += 'Â¾'
	end
      end
      char_type
    end

    def get_unknown(form)
      if char_type(form).size > 1 then
	nil
      else
	m = ChadicMorph.new([form, 17, 0, 0, 1, 1340])
	m.is_unknown = true
	m
      end
    end
  end
end
