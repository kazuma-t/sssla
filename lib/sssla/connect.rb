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
# $Id: connect.rb,v 1.2 2001/12/06 16:06:08 kazuma-t Exp $

class Sssla
  class ConnectPair
    attr_accessor :index, :i_pos, :j_pos, :pos, :type, :form, :lex
  end
  class ConnectRule
    attr_accessor :next, :cost
  end
  class ConnectMatrix
    def initialize(table_file, matrix_file)
      GC.disable
      @table = Marshal.load(open(table_file))
      @matrix = Marshal.load(open(matrix_file))
      GC.enable
    end
    def check_automaton(state, con, undef_con_cost)
      cell = @matrix[state][@table[con].j_pos]
      cost = cell.cost
      if cost == 0
	cost = undef_con_cost
      else
	cost -= 1
      end
      return [@table[cell.next + con].i_pos, cost]
    end
    def get_con_tbl(pos_id)
      @table.each_index do |i|
	if @table[i].pos == pos_id then
	  return i
	end
      end
      return -1
    end
  end
end
