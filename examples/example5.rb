require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example5.log')

l.log "Starting example5.rb!"
BlackStack::Appending.set_logger(l)
h = BlackStack::Appending.find_person('Jeff', 'Bezos', 'Amazon')[:matches].first
p BlackStack::Appending.value(h, :email)
