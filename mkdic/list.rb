#
# read s-expression and build lists in arrays
#
# $Id$

require 'delegate'
require 'strscan'

class ListBuilder < DelegateClass(Array)
  def initialize
    @stack = []
    @root = []
    super(@root)
  end

  def parse(string)
    @current = @root if @current.nil?
    @scan = StringScanner.new(string)
    make_list()
  end

  def get_list
    @root
  end

  private
  def scan
    while !@scan.empty? do
      @scan.skip(/\A\s+/o)
      if tmp = @scan.scan(/\A;.*\n/o) then
	next
      elsif tmp = @scan.scan(/\A\(/o) then
	return [:OPEN, tmp]
      elsif tmp = @scan.scan(/\A\)/o) then
	return [:CLOSE, tmp]
      elsif tmp = @scan.scan(/\A\d+/o) then
	return [:NUMBER, tmp.to_i]
      elsif tmp = @scan.scan(/\A[^\)\s]+/o) then
	return [:TERM, tmp]
      end
    end
    nil
  end

  def make_list
    while true
      symbol, term = scan
      break if symbol.nil?
      case symbol
      when :OPEN
	@stack.push(@current)
	@current = []
      when :CLOSE
	p_list = @stack.pop
	p_list.push(@current)
	@current = p_list
      else
	@current.push(term)
      end
    end
    @stack.empty?
  end
end
