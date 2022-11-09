require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'

BlackStack::CSVIndexer.index('ix_linkedin_url_01')

