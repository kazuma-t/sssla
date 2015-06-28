require 'connect'

matrix = Chasen::ConnectMatrix.new(open("table.sss"), open("matrix.sss"))
puts matrix.get_con_tbl(ARGV[0].to_i)
