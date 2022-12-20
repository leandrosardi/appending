require 'appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example3.log')

l.log "Starting example3.rb!"
BlackStack::Appending.set_logger(l)
results = BlackStack::Appending.find_persons_with_full_name('Elon Musk', 'SpaceX')
puts "Total records found: #{results.size}"
puts "Total enlapsed seconds: #{BlackStack::Appending.report[:enlapsed_seconds]}"
puts "Total files processed: #{BlackStack::Appending.report[:files_processed]}"