require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example5.log')

l.log "Starting example5.rb!"
BlackStack::Appending.set_logger(l)

# Getting a VERIFIED email of Elon Musk
p BlackStack::Appending.find_verified_emails('Jackson', 'Wise', 'Comma Insurance')