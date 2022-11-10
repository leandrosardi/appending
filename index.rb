require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'

#l = BlackStack::BaseLogger.new(nil)

BlackStack::CSVIndexer.indexes.each { |i|
#    l.logs "Indexing #{i.name}..."
    i.index
#    l.done
}

#BlackStack::CSVIndexer.index('ix_linkedin_url_01')

