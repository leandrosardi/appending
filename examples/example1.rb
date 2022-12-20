require_relative '../lib/appending'
require_relative './config'

l = BlackStack::LocalLogger.new('./example1.log')

#l.log "Starting example1.rb!"
#BlackStack::Appending.set_logger(l)

# Looking for possible emails of Elon Musk 
p BlackStack::Appending.find_persons('Elon', 'Musk', 'SpaceX').map { |res| 
    res.emails 
}.flatten.uniq.reject { |email|
    email.empty?
}
# => ["emusk@spacex.com", "elon@spacex.com", "elon.musk@spacex.com", "elonmusk@spacex.com", "musk@spacex.com"]
