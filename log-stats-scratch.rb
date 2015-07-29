#!/usr/bin/env ruby

infile = File.open(ARGV[0], 'r')
regex = /\"GET(.*)HTTP/
matches = {}
infile.each_line { |line|
	if line =~ regex

		thisMatch = $~.captures[0].to_sym

		if matches.has_key?(thisMatch)
			matches[thisMatch] += 1
		else
			matches[thisMatch] = 1
		end
	end
}

# infile = File.open(ARGV[0], 'r')
# regex = /\"GET(.*)HTTP/
# matches = {}
# infile.each_line { |line|
# 	if line =~ regex

# 		thisMatch = $~.captures[0].to_sym

# 		if matches.has_key?(thisMatch)
# 			matches[thisMatch] += 1
# 		else
# 			matches[thisMatch] = 1
# 		end
# 	end
# }

#matches.keys[1..10].each { |key| puts "#{key} => #{matches[key]}" }

matches = Hash[matches.sort_by { |k,v| [-Integer(v), k] }]

matches.keys[0..10].each { |key| puts "#{key} => #{matches[key]}" }

# begin
# 	infile = File.open(ARGV[0], 'r')
# 	regex = /\"GET(.*)HTTP/
# 	matches = {}
# 	infile.each_line { |line|
# 	if line =~ regex
# 		thisMatch = $~.captures[0].to_sym
# 		if matches.has_key?(thisMatch)
# 			matches[thisMatch] += 1
# 		else
# 			matches[thisMatch] = 1
# 		end
# 	end
# }
# 	matches = Hash[matches.sort_by {|k,v| v}.reverse]
# rescue IOError => e
# 	STDERR.puts "Infile error! #{e}"
# 	infile.close
# 	exit 1
# rescue => e
# 	STDERR.puts "File error! #{e}"
# 	exit 1
# end