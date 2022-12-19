require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example6.log')

l.log "Starting example6.rb!"
BlackStack::Appending.set_logger(l)
p BlackStack::Appending.find_person('Jeff', 'Bezos', 'Amazon')[:matches].map { |h| BlackStack::Appending.value(h, :email) }
