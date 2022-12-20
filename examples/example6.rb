require 'appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example6.log')

l.log "Starting example6.rb!"
BlackStack::Appending.set_logger(l)

# Looking for the phone number of 
p BlackStack::Appending.find_persons('Jackson', 'Wise', 'Comma Insurance').map { |res| 
    res.phones
}.flatten.uniq.reject { |phone|
    phone.empty?
}