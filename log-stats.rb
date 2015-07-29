#!/usr/bin/env ruby

# Name: 		log-stats.rb
# Author: 		Rachael Birky
# Description: 	This script analyzes a log file and
# 					displays results filtered by given flags

# Include GetoptLong Module
require 'getoptlong'

opts = GetoptLong.new(
	[ '--help', GetoptLong::NO_ARGUMENT ],
	[ '--resources', GetoptLong::NO_ARGUMENT ], 
	[ '--requesters', GetoptLong::NO_ARGUMENT ],
	[ '--errors', GetoptLong::NO_ARGUMENT ],
	[ '--hourly', GetoptLong::NO_ARGUMENT ],
	[ '--number', '-n', GetoptLong::REQUIRED_ARGUMENT]
)

# Declare variable to hold display number (if specified)
$number = 0
$hourly = false
$matches = {}
$stdError = "\n\tUsage: ruby log-stats.rb [OPTION] PATH/TO/FILE\n\tHelp:  ruby log-stats.rb --help"

# Internal method help: prints the usage of this script
# ==== Attribute
# * none
# ==== Options
# * none
# ==== Example
# => help
def help
	puts <<-EOF

	ruby log-stats.rb [OPTION] PATH/TO/FILE

	--help:
		displays usage/options and exits

	--resources
		displays the counted resources in descending order

	--requesters
		displays the counted IPs requested in descending order

	--errors
		displays the counted resources with HTTP status codes 400-599

	--hourly
		displays the total number of requests within each hour, sorted by hour

	EOF
	exit 0
end

# Internal method verifyFlagNum: ensures only one flag has been used
# ==== Attribute
# * none
# ==== Options
# * none
# ==== Example
# => verifyFlagNum
def verifyFlagNum
	optsEx = ['--help', '--resources', '--requesters', '--errors', '--hourly']
	optCount = 0
	ARGV.each { |arg|
		if optsEx.include?(arg)
			optCount += 1
		end
	}
	if optCount > 1
		STDERR.puts "Too many options selected"+$stdError
		exit 1
	end
end

# Internal method verifyFile: checks existence of given file
# ==== Attribute
# * infileName : name of file with log stats
# ==== Options
# * none
# ==== Example
# => verifyFile(./access_log_2012_02_21)
def verifyFile(infileName)
	begin
		infile = File.open(infileName, 'r')
	rescue => e
		STDERR.puts "File error! #{e}"+$stdError
		exit 1
	end
end

# Internal method resources: hashes resources and number of times called
# ==== Attribute
# * infileName : name of file with log stats
# ==== Options
# * none
# ==== Example
# => resources(./access_log_2012_02_21)
def resources(infileName)
	verifyFile(infileName)
	infile = File.open(infileName, 'r')
	regex = /"[A-Z]+\s(.*)HTTP/
	infile.each_line { |line|
		if line =~ regex
			thisMatch = $~.captures[0].to_sym
			if $matches.has_key?(thisMatch)
				$matches[thisMatch] += 1
			else
				$matches[thisMatch] = 1
			end
		end
	}
	$matches = Hash[$matches.sort_by { |k,v| [-Integer(v), k] }]
end

# Internal method requesters: hashes requesting IPs and number of times called
# ==== Attribute
# * infileName : name of file with log stats
# ==== Options
# * none
# ==== Example
# => requesters(./access_log_2012_02_21)
def requesters(infileName)
	verifyFile(infileName)
	infile = File.open(infileName, 'r')
	regex = /\A\d{1,3}\.\d{1,3}\.\d{1,3}/
	infile.each_line { |line|
	if line =~ regex
		thisMatch = regex.match(line)
		thisMatch = thisMatch[0].to_sym
		if $matches.has_key?(thisMatch)
			$matches[thisMatch] += 1
		else
			$matches[thisMatch] = 1
		end
	end
	}
	$matches = Hash[$matches.sort_by { |k,v| [v.to_i, k.to_s.split('.').map{ |numGroup| numGroup.to_i}]}.reverse!]
end

# Internal method errors: hashes resources with errors and number of times called
# ==== Attribute
# * infileName : name of file with log stats
# ==== Options
# * none
# ==== Example
# => errors(./access_log_2012_02_21)
def errors(infileName)
	verifyFile(infileName)
	infile = File.open(infileName, 'r')
	regex = /\s((4|5)[0-9][0-9])\s(\d{3}|-)/
	resource = /\"[A-Z]+\s(.*)HTTP/
	matches = {}
	infile.each_line { |line|
		if line =~ regex
			thisMatch = resource.match(line)
			thisMatch = $~.captures[0].to_sym
			if $matches.has_key?(thisMatch)
				$matches[thisMatch] += 1
			else
				$matches[thisMatch] = 1
			end
		end
	}
	$matches = Hash[$matches.sort_by {|k,v| [-Integer(v),k]}]
end

# Internal method hourly: hashes number of resources per hour
# ==== Attribute
# * infileName : name of file with log stats
# ==== Options
# * none
# ==== Example
# => hourly(./access_log_2012_02_21)
def hourly(infileName)
	verifyFile(infileName)
	infile = File.open(infileName, 'r')
	regex = /\d{4}:(\d{2}):(\d{2}):(\d{2})\s/
	matches = {}
	infile.each_line { |line|
		if line =~ regex
			thisMatch = regex.match(line)
			thisMatch = $~.captures[0].to_s+":00"
			thisMatch = thisMatch.to_sym
			if $matches.has_key?(thisMatch)
				$matches[thisMatch] += 1
			else
				$matches[thisMatch] = 1
			end
		end
	}
	$matches = Hash[$matches.sort_by {|k,v| k }]
end

########
# MAIN #
########

verifyFlagNum

# Parse flags
begin
	opts.each do |opt, arg|

		case opt
			when '--help'
				if ARGV.length > 0
					raise GetoptLong::NeedlessArgument
				else
					help
				end

			when '--resources'
				$option = :resources
				#resources(ARGV[0])

			when '--requesters'
				$option = :requesters
				#requesters(ARGV[0])

			when '--errors'
				$option = :errors
				#errors(ARGV[0])

			when '--hourly'
				$hourly = true
				$option = :hourly
				#hourly(ARGV[0])

			when '--number'
				if (arg =~ /\A[^-]\d*\Z/) == 0
					$number = arg
				else
					STDERR.puts "Error: Integer required"+$stdError
					exit 1
				end
			else
				STDERR.puts "Error: invalid option"+$stdError
				exit 1
		end
	end
rescue GetoptLong::Error => e
	STDERR.puts "Error! #{e}."+$stdError
  	exit 1
end

# Call appropriate method according to option
case $option
	when :resources
		resources(ARGV[0])
	when :requesters
		requesters(ARGV[0])
	when :errors
		errors(ARGV[0])
	when :hourly
		hourly(ARGV[0])
end

# Print results according to selection
if $hourly
	# FOR HOURLY
	if $number.to_i > 0
		$matches.keys[0..$number.to_i-1].each { |k| printf "%10s \t %s \n", k, $matches[k] }
	else
		$matches.each { |k,v| printf "%10s \t %s \n", k, v }
	end
else
	if $number.to_i > 0
		$matches.keys[0..$number.to_i-1].each { |k| printf "%10s \t %s \n", $matches[k], k }
	else
		$matches.each { |k,v| printf "%10s \t %s \n", v, k }
	end
end