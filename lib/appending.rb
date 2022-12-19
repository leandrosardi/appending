require 'csv'
require 'csv-indexer'
require 'simple_cloud_logging'

module BlackStack
    module Appending
        @@logger = nil

        def self.set_logger(logger)
            @@logger = logger
        end

        def self.logger
            @@logger
        end

=begin # TODO: Move this to a `verification` gem
        # return true if the domain get any random address as valid
        def self.catch_all?(domain)
            BlackStack::Appending.verify("008e77980535470e848a4ca859a83db0@#{domain}")
        end

        # verify an email address using the AWS IP address of our website, wich is more reliable
        def self.verify(email)
            url = "https://connectionsphere.com/api1.0/emails/verify.json"
            params = {
                :email => email,
            }
            res = BlackStack::Netting::call_get(url, params)
            parsed = JSON.parse(res.body)
            parsed['status'] == 'success'
        end

        # verify an email address
        def self.append(fname, lname, domain)
            ret = []
            if !catch_all?(domain)
                EmailVerifier.config do |config|
                    config.verifier_email = "leandro.sardi@expandedventure.com"
                end
                [
                    "#{fname}@#{domain}",
                    "#{lname}@#{domain}",

                    "#{fname}.#{lname}@#{domain}",
                    "#{lname}.#{fname}@#{domain}",

                    "#{fname}#{lname}@#{domain}",
                    "#{lname}#{fname}@#{domain}",

                    "#{fname[0]}#{lname}@#{domain}",
                    "#{fname[0]}.#{lname}@#{domain}",
                ].each { |email|
                    ret << email.downcase if verify(email)
                }
            end
            ret
        end
=end

        # This is a support method for the `append` methods.
        # The end-user should not call this method directly.
        def self.cleanup_fname(name)
            return '' if name.nil?
            a = name.split(/[^a-zA-Z]/)
            a.size > 0 ? a[0] : ''
        end

        # This is a support method for the `append` methods.
        # The end-user should not call this method directly.
        def self.cleanup_lname(name)
            return '' if name.nil?
            a = name.split(/[^a-zA-Z]/)
            a.size > 1 ? a[1] : ''
        end

        # This is a support method for the `append` methods.
        # The end-user should not call this method directly.
        def self.cleanup_company(company)
            return '' if company.nil?
            ret = ''
            # stage 1: remove company-type suffixes
            company = company.split(/ at /).last
            company.gsub!(/LLC/, '')
            company.gsub!(/Inc/, '')
            company.strip! # remove leading and trailing spaces
            # stage 2: remove LinkedIn suffixes            
            company.gsub!(/\(\d\d\d\d - Present\)/, '')
            company.strip! # remove leading and trailing spaces
            # stege 3: remove non-alphanumeric characters
            company.gsub!(/\.$/, '')  
            company.gsub!(/\,$/, '') 
            # stege 4: remove extra spaces
            company.gsub!(/[^a-zA-Z0-9,\.\-\s]/, '') # remove extra spaces
            company.strip! # remove leading and trailing spaces
            # stage 5: choose the first part of the company name
            company.split(' ').each { |word|
                ret += word + ' '
                #break if word.size >= 5 || ret.split(' ').size > 2
                break if ret.split(' ').size > 2
            } 
            ret.strip!
            # return
            ret
        end

        # Find a person in the indexes by its full name and company name.
        # Append all the information in the index row.
        def self.find_person_with_full_name(name, cname)
            l = BlackStack::Appending.logger || BlackStack::DummyLogger.new

            l.logs "Guessing fname from #{name}... "
            fname = BlackStack::Appending::cleanup_fname(name)
            l.logf fname

            l.logs "Guessing lname from #{name}... "
            lname = BlackStack::Appending::cleanup_lname(name)
            l.logf lname

            BlackStack::Appending.find_person(fname, lname, cname)
        end

        # Find a person in the indexes by its first name, last name and company name.
        # Append all the information in the index row.
        def self.find_person(fname, lname, cname)
            l = BlackStack::Appending.logger || BlackStack::DummyLogger.new
            total = {
                :matches => [],
                :enlapsed_seconds => 0,
                :files_processed => 0,
            }
            # cleaning up company name
            l.logs "Cleaning up company name #{cname}... "
            cname = BlackStack::Appending::cleanup_company(cname)
            l.logf cname
            # looking for a record that matches with first name, last name and company name
            appends = []
            enlapsed_seconds = 0
            files_processed = 0
            BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /persona/ }.each { |i|
                l.logs "Searching into #{i.name}... "
                ret = i.find([cname, fname, lname], false, nil)
                # add matches to the list
                total[:matches] += ret[:matches]
                # sum the total files and the total enlapsed seconds                
                total[:enlapsed_seconds] += ret[:enlapsed_seconds]
                total[:files_processed] += ret[:files_processed]
                l.done
            }
            # return
            total
        end

        # Find a company in the indexes by its first name, last name and company name.
        # Append all the information in the index row.
        def self.find_company(cname)
            l = BlackStack::Appending.logger || BlackStack::DummyLogger.new
            # TODO: Code Me!
        end


    end # Appending
end # BlackStack