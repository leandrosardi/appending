require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example2.log')

l.log "Starting example2.rb!"
BlackStack::Appending.set_logger(l)
p BlackStack::Appending.find_person_with_full_name('Elon Musk', 'SpaceX')
