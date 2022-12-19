require 'csv-indexer'
require_relative './config'

BlackStack::CSVIndexer.indexes.each { |i|
    i.index(true)
}


