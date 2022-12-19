require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example7.log')

l.log "Starting example7.rb!"
BlackStack::Appending.set_logger(l)
p BlackStack::Appending.find_person('Jeff', 'Bezos', 'Amazon')[:matches].map { |h| BlackStack::Appending.emails(h) }.flatten
