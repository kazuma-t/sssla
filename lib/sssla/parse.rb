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
# $Id: parse.rb,v 1.2 2001/12/06 16:06:09 kazuma-t Exp $

require 'sssla/graph'
require 'sssla/dic'

class Sssla
  class Parser
    def initialize(pos_tbl, inflect, dic, connect_matrix, unknown)
      @pos_tbl = pos_tbl
      @inflect = inflect
      @dic = dic
      @connect_matrix = connect_matrix
      @unknown = unknown
    end
    def parse(string)
      @graph = Sssla::Graph.new(@connect_matrix, @pos_tbl, 10000)
      @unknown.set_graph(@graph)
      cursor = 0
      string.split('').collect{|c| c.length}.each do |clen|
	morphs = @dic.lookup(string, cursor)
	morphs.each do |m|
	  @graph.set_morph(m, cursor)
	end
	cursor += clen
      end
      @graph.set_end(cursor)
      @graph.best_path
    end
  end
end
