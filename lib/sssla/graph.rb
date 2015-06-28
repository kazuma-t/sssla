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
# $Id: graph.rb,v 1.4 2002/01/05 05:51:19 kazuma-t Exp $

require 'sssla/connect'

class Sssla
  MORPH_COST_WEIGHT = 1
  MORPH_DEFAULT_WEIGHT = 1
  DEFAULT_C_WEIGHT = 10
  CONNECT_COST_WEIGHT = 1
  CONNECT_COST_UNDEF = 10000

  class Node
    attr_reader :morph
    attr_accessor :cost, :state, :prev
    def initialize(morph)
      @morph = morph
      @prev = []
      @cost = 0
    end
  end
  class BOS < Node
    def initialize
      super(ChadicMorph.new(['', 0, 0, 0,
			      MORPH_DEFAULT_WEIGHT, 0, nil]))
      @cost = 0
      @state = 0
    end
  end
  class Graph
    attr_accessor :end_list
    def initialize(connect_matrix, pos_tbl, cost_width = -1)
      @matrix = connect_matrix
      @pos_tbl = pos_tbl
      @cost_width = cost_width
      @connect_cost_undef = Sssla::CONNECT_COST_UNDEF
      @connect_cost_weight = Sssla::CONNECT_COST_WEIGHT
      @morph_cost_weight = Sssla::MORPH_COST_WEIGHT
      @end_list = []
      @end_list[0] = [BOS.new]
    end
    def set_morph(morph, cursor)
      if @end_list[cursor] == nil then
	return
      end
      nodes = connect(morph, cursor)
      tail = cursor + morph.lex.size
      if @end_list[tail].nil? then
	@end_list[tail] = []
      end
      nodes.each do |node|
	@end_list[tail].push(node)
      end
    end
    def set_end(cursor)
      set_morph(ChadicMorph.new(['EOS', 0, 0, 0,
				  MORPH_DEFAULT_WEIGHT, 0, nil]),
		cursor)
    end

    def best_path
      path = []
      prev = [@end_list[-1]]
      while !prev.empty? do
	path.push(prev[0][0])
	prev = prev[0][0].prev
      end
      # remove BOS
      if path[-1].morph.pos_id == 0 then
	path.pop
      end
      path.reverse
    end

    private
    def sort_state(morph, cursor)
      state_list = Hash.new
      @end_list[cursor].each do |prev|
	state, con_cost = @matrix.check_automaton(prev.state,
						  morph.con_tbl,
						  @connect_cost_undef)
	if con_cost < 0 then
	  next
	end
	cost = prev.cost + con_cost * @connect_cost_weight

	entry = state_list[state]
	if entry.nil? then
	  entry = state_list[state] = [cost, [[prev, cost]]] # [min, prev_list]
	else
	  if cost - entry[0] > @cost_width then
	    next
	  end
	  if entry[0] > cost then
	    entry[0] = cost
	    entry[1].unshift([prev, cost])
	  else
	    entry[1].push([prev, cost])
	  end
	end
      end

      state_list.each_value do |entry|
	max_cost = entry[0] + @cost_width
	entry[1].delete_if {|p| p[1] > max_cost}
      end
      state_list
    end
    def connect(morph, cursor)
      nodes = []
      morph_cost = 
	if morph.is_unknown then
	  30000 + 500 * morph.lex.size / 2
	elsif morph.is_estimate then
	  @pos_tbl.get_weight(morph.pos_id)
	else
	  @pos_tbl.get_weight(morph.pos_id)
	end
      morph_cost *= morph.weight * @morph_cost_weight
      sort_state(morph, cursor).each do |state, entry|
	node = Node.new(morph)
	node.cost = entry[0] + morph_cost
	node.state = state
	node.prev = entry[1]
	nodes.push(node)
      end
      nodes
    end
  end
end
