require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example1.log')

l.log "Starting example1.rb!"
BlackStack::Appending.set_logger(l)
p BlackStack::Appending.find_persons('Elon', 'Musk', 'SpaceX').map { |res| res.emails }.flatten.uniq
