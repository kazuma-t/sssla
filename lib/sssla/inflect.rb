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
# $Id: inflect.rb,v 1.4 2001/12/12 03:23:56 kazuma-t Exp $

class Sssla
  class InfType
    attr_accessor :name, :basic, :form
    def initialize
      @form = []
    end
  end
  class InfForm
    attr_accessor :name, :ending, :r_ending, :p_ending
    def initialize(*args)
      @name, @ending, @r_ending, @p_ending = args
    end
  end
  class Inflection
    def initialize(inf_file)
      @inftypes = Marshal.load(open(inf_file))
    end
    def get_inf_form(inf_type)
      if inf_type != 0
	@inftypes[inf_type].form
      else
	nil
      end
    end
    def get_type_name(inf_type)
      if inf_type != 0
	@inftypes[inf_type].name
      else
	nil
      end
    end
    def get_form_name(inf_type, inf_form)
      if inf_type != 0 && inf_form != 0
	@inftypes[inf_type].form[inf_form].name
      else
	nil
      end
    end
    def get_basic_ending(inf_type)
      if inf_type != 0
	@inftypes[inf_type].basic.ending
      else
	nil
      end
    end
    def get_r_ending(inf_type, inf_form)
      if inf_type != 0 && inf_form != 0 then
	@inftypes[inf_type].form[inf_form].r_ending
      else
	nil
      end
    end
    def get_p_ending(inf_type, inf_form)
      if inf_type != 0 && inf_form != 0 then
	@inftypes[inf_type].form[inf_form].p_ending
      else
	nil
      end
    end
    def get_type_id(name)
      @inftypes.each_index do |id|
	if id != 0 and @inftypes[id].name == name then
	  return id
	end
      end
      nil
    end
    def get_basic_form_id(inf_type)
      @inftypes[inf_type].form.each_index do |id|
	if id != 0 and
	    @inftypes[inf_type].form[id] == @inftypes[inf_type].basic then
	  return id
	end
      end
      nil
    end
  end
end
