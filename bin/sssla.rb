#!/usr/bin/env ruby
#
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
# $Id: sssla.rb,v 1.8 2002/01/05 05:49:43 kazuma-t Exp $

require 'getoptlong'
require 'sssla/main'

if !ENV['SSSLA_DIC_DIR'].nil? then
  $SSSLA_DIC_DIR = ENV['SSSLA_DIC_DIR']
end

def show_help
  show_version()
  puts <<EOS
Usage: sssla [option] [file..]
Options:
--grammar-dir, -g DIR    use dictionary and grammar files in DIR directory
--help                   show this help
--version                show version
EOS
end

def show_version
    puts 'Sssla ' + Sssla.version
end

opt_parser = GetoptLong.new.set_options(
  ['--grammar-dir', '-g', GetoptLong::REQUIRED_ARGUMENT],
  ['--help',              GetoptLong::NO_ARGUMENT],
  ['--version',           GetoptLong::NO_ARGUMENT])

begin
  opt_parser.each do |opt, dat|
    case opt
    when '--grammar-dir'
      $SSSLA_DIC_DIR = dat
    when '--help'
      show_help()
      exit
    when '--version'
      show_version()
      exit
    end
  end
rescue GetoptLong::InvalidOption
  show_help()
  exit
end

if $SSSLA_DIC_DIR.nil? then
  $SSSLA_DIC_DIR = '.'
end

sssla = Sssla.new($SSSLA_DIC_DIR)

ARGF.each do |line|
  sssla.parse(line.chomp).each do |n|
    lex = n.morph.lex
    basic = n.morph.basic_form
    reading = n.morph.reading
    pron = n.morph.pronounce
    pos = (n.morph.is_unknown) ? 'Ì¤ÃÎ¸ì' : n.morph.pos_fullname
    itype = n.morph.inf_type_name
    iform = n.morph.inf_form_name
    if pos == 'EOS' then
      puts 'EOS'
    else
      puts [lex, reading, pron, basic, pos, itype, iform].join("\t")
    end
    STDOUT.flush
  end
end
