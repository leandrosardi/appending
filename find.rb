require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

l = BlackStack::BaseLogger.new(nil)

# open CSV file
input = CSV.open('./searches/padilla.trustandsafety.csv', 'r')

# iterate through each row
i = 0
input.each { |row|
    i += 1
    # get the full name
    name = row[0]
    fname = BlackStack::Appending::cleanup_fname(name)
    lname = BlackStack::Appending::cleanup_lname(name)
    # get the company name
    company = row[1]
    cname = BlackStack::Appending::cleanup_company(company)
    # log
    l.logs "#{i.to_s}. #{fname} #{lname} at #{cname}... "
    matches = []
    enlapsed_seconds = 0
    BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /ix\.persona/ }.each { |i|
        l.logs "Searching into #{i.name}..."
        ret = i.find([company, fname, lname], false, nil)
        matches += ret[:matches]
        enlapsed_seconds += ret[:enlapsed_seconds]
        l.logf "#{ret[:matches].to_s}. #{ret[:files_processed].to_s} files processed. #{ret[:enlapsed_seconds]} seconds."
    }
    l.logf "Found #{matches.size} matches in #{enlapsed_seconds} seconds."
}


