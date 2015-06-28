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
# $Id: dic.rb,v 1.5 2002/01/29 09:43:46 kazuma-t Exp $

require 'wary'
require 'mmap'
require 'sssla/morph'
require 'sssla/inflect'

class Sssla
  class Dictionary
    def initialize(pos_tbl, inflect, lex_file, wary_file, unknown)
      @pos_tbl = pos_tbl
      @inflect = inflect
      @wary = Wary.load(wary_file)
      @lexs = Mmap.new(lex_file)
      @unknown = unknown
    end

    def lookup(str, cursor)
      string = str[cursor..-1]
      morphs = []
      @wary.lookup2(string).each do |entry|
	len, index = entry
	form = string[0...len]
	entry_num = @lexs[index]
	index += 1
	entry_num.times do |entry|
	  morph_data = @lexs[index, 12].unpack('nCCnnN')
	  index += 12
	  morphs.concat(get_morph(string, form, morph_data))
	end
      end
      in_dic = []
      morphs.each do |m|
	in_dic[m.lex.size] = true
      end
      length = 0
      string.split("").collect{|c| c.length}.each do |clen|
 	length += clen
	if !in_dic[length] then
 	  unknown = @unknown.estimate(string, length, cursor)
 	  if !unknown.nil? then
 	    morphs.push(unknown)
 	  end
	end
      end
      morphs
    end

private

    def get_morph(string, base_form, morph_data)
      morph_data = morph_data.unshift(base_form)
      morphs = Array.new
      new_morph = morph = ChadicMorph.new(morph_data)
      lex = morph.lex
      con_tbl = morph.con_tbl
      if morph.inf_type != 0 then
	if morph.inf_form != 0 then
	  morph.base_len = 0
	  morphs.push(morph)
	else
	  inf_forms = @inflect.get_inf_form(morph.inf_type)
	  (1...inf_forms.size).each {|form|
	    ending = inf_forms[form].ending
	    if ending == string[base_form.size, ending.size]
	      if new_morph == nil
		new_morph = morph.dup
	      end
	      new_morph.inf_form = form
	      new_morph.lex = lex + ending
	      new_morph.con_tbl = con_tbl + form - 1
	      morphs.push(new_morph)
	      new_morph = nil
	    end
	  }
	end
      else
	morphs.push(morph)
      end
      morphs
    end
  end
end
