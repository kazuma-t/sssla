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
# $Id: morph.rb,v 1.5 2002/01/29 09:44:21 kazuma-t Exp $

class Sssla
  class Morph
    @@pos_tbl = nil
    @@inflect = nil
    @@dat = nil
    attr_accessor :lex, :pos_id
    attr_accessor :inf_type, :inf_form
    attr_accessor :con_tbl, :comp, :weight
    attr_accessor :base_len
    attr_accessor :is_unknown, :is_estimate
    attr_accessor :dat_index

    def initialize
      @is_unknown = false
      @is_estimate = false
    end

    def Morph.set_param(pos_tbl, inflect, dat)
      @@pos_tbl = pos_tbl
      @@inflect = inflect
      @@dat = dat
    end

    def pos_fullname
      @@pos_tbl.get_fullname(@pos_id)
    end

    def inf_type_name
      @@inflect.get_type_name(@inf_type)
    end

    def inf_form_name
      @@inflect.get_form_name(@inf_type, @inf_form)
    end

    def basic_form
      if @basic_form.nil? then
	@basic_form = get_data(@@dat)[2]
	if @basic_form == '' then
	  if @inf_type != 0
	    @basic_form = @lex[0, @base_len] +
	      @@inflect.get_basic_ending(@inf_type)
	  else
	    @basic_form = @lex
	  end
	end
      end
      @basic_form
    end

    def reading
      if @reading.nil? then
	if @base_len == 0 then
	  @reading = ''
	else
	  @reading = get_data(@@dat)[0]
	end
	if @inf_type != 0 then
	  @reading += @@inflect.get_r_ending(@inf_type, @inf_form)
	end
      end
      @reading
    end

    def pronounce
      if @pron.nil? then
	if @base_len == 0 then
	  @pron = ''
	else
	  @pron = get_data(@@dat)[1]
	end
	if @inf_type != 0 then
	  @pron += @@inflect.get_p_ending(@inf_type, @inf_form)
	end
      end
      @pron
    end

    private
    def get_data(dat)
      if !@lex_data.nil? then
	return @lex_data
      end
      if @pos_id == 0 or @dat_index.nil? then
	return @lex_data = [nil, nil, nil, nil]
      end
      @lex_data = []
      len = dat[@dat_index, 4].unpack('CCCC')
      index = @dat_index + 4
      @lex_data[0] = dat[index, len[0]]	# reading
      index += len[0]
      @lex_data[1] = dat[index, len[1]]	# pron
      index += len[1]
      @lex_data[2] = dat[index, len[2]]	# base
      index += len[2]
      @lex_data[3] = dat[index, len[3]]	# info
      if @lex_data[1] == '' then
	@lex_data[1] = @lex_data[0]
      end
      @lex_data
    end
  end

  class ChadicMorph < Morph
    def initialize(entry)
      super()
      @lex, \
      @pos_id, @inf_type, @inf_form, \
      @weight, @con_tbl, @dat_index, comps = entry
      @base_len = @lex.size
      if (comps != nil) then
	@comp = comps.collect {|comp_ent| ChadicMorph.new(comp_ent)}
      end
    end
  end
end
