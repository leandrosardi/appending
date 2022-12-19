require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example3.log')

l.log "Starting example3.rb!"
BlackStack::Appending.set_logger(l)
h = BlackStack::Appending.find_person_with_full_name('Elon Musk', 'SpaceX')
puts "Total records found: #{h[:matches].size}"
puts "Total enlapsed seconds: #{h[:enlapsed_seconds]}"
puts "Total files processed: #{h[:files_processed]}"