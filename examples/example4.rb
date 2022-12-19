require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example4.log')

l.log "Starting example4.rb!"
BlackStack::Appending.set_logger(l)
p BlackStack::Appending.find_company('SpaceX')