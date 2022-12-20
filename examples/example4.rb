require 'appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example4.log')

#l.log "Starting example4.rb!"
#BlackStack::Appending.set_logger(l)

# Looking for people working at SpaceX
puts BlackStack::Appending.find_persons_by_company('SpaceX').map { |res| 
    res.val(:first_name).capitalize + 
    ' ' + 
    res.val(:last_name).capitalize 
}.flatten.uniq.sort.join("\n")
# => Abel Gonzalez
# => Abraham Villa
# => Alan Keisner
# => Albert Arteaga
# => Albertine Scott
# => ...
# => Zachary Hose

