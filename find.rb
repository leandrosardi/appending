require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

#l = BlackStack::BaseLogger.new(nil)

# open CSV file
input = CSV.open('./searches/padilla.trustandsafety.csv', 'r')

# iterate through each row
input.each { |row|
    # get the full name
    name = row[0]
    fname = BlackStack::Appending::cleanup_fname(name)
    lname = BlackStack::Appending::cleanup_lname(name)
    # get the company name
    company = row[1]
    # log
    puts "#{fname} #{lname} at #{company}"
}
=begin
BlackStack::CSVIndexer.indexes.each { |i|
#    l.logs "Indexing #{i.name}..."
    i.index.index
#    l.done
}
=end
#BlackStack::CSVIndexer.index('ix_linkedin_url_01')

