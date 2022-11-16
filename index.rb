require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'

BlackStack::CSVIndexer.indexes.each { |i|
    i.index(true)
}


