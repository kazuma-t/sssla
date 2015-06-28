#!/usr/bin/env ruby

chadic_dir = ARGV[0]
if chadic_dir.nil? then
  puts 'Usage: ruby makeall.rb CHADICDIR'
  exit
end

system("ruby cha2sss.rb #{chadic_dir} pos.sss inf.sss")
system("ruby convmatrix.rb #{chadic_dir} table.sss matrix.sss")
system("ruby mkdic.rb #{chadic_dir} chadic")
