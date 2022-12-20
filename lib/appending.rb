require 'csv'
require 'csv-indexer'
require 'simple_cloud_logging'

module BlackStack
    module Appending
        @@logger = nil
        @@report = nil
        @@indexes = []
        @@verifier_url = 'https://connectionsphere.com/api1.0/emails/verify.json'
        @@verifier_api_key = nil
        @@email_fields = []
        @@phone_fields = []
        @@company_domain_fields = []

        ## @@logger
        def self.set_logger(logger)
            @@logger = logger
        end

        def self.logger
            @@logger
        end

        ## @@indexes
        def self.add_index(index)
            expected = [:company_name, :first_name, :last_name]

            # validation: keys must be `[:company_name, :first_name, :last_name]`
            if !index.keys.eql?(expected)
                raise "Invalid index: #{index.keys}. Expected: #{expected}."
            end
            # add the index
            @@indexes << index
        end

        def self.set_indexes(indexes)
            @@indexes = indexes
        end
        
        def self.indexes
            @@indexes
        end

        # @@report
        def self.report
            @@report
        end

        # @@verifier_url
        def self.set_verifier_url(url)
            @@verifier_url = url
        end
        
        def self.verifier_url
            @@verifier_url
        end

        # @@verifier_api_key
        def self.set_verifier_api_key(key)
            @@verifier_api_key = key
        end

        def self.verifier_api_key
            @@verifier_api_key
        end

        # @@email_fields
        def self.set_email_fields(fields)
            @@email_fields = fields
        end

        def self.email_fields
            @@email_fields
        end

        # @@phone_fields
        def self.set_phone_fields(fields)
            @@phone_fields = fields
        end

        def self.phone_fields
            @@phone_fields
        end

        # @@company_domain_fields
        def self.set_company_fields(fields)
            @@company_domain_fields = fields
        end

        def self.company_domain_fields
            @@company_domain_fields
        end

        # set configuration
        def self.set(h)
            errors = []

            # validation: if :indexes is present, it must be an array of objects BlackStack::CSVIndexer::Index
            if h[:indexes]
                if !h[:indexes].is_a?(Array)
                    errors << "Invalid :indexes: #{h[:indexes].class}. Expected: Array."
                else
                    h[:indexes].each { |index|
                        if !index.is_a?(BlackStack::CSVIndexer::Index)
                            errors << "Invalid :indexes: #{index.class}. Expected: BlackStack::CSVIndexer::Index."
                        end
                    }
                end
            end

            # validation: if :verifier_url is present, it must be a string
            errors << ":verifier_url must be a string." if h[:verifier_url] && !h[:verifier_url].is_a?(String)

            # validation: if :verifier_api_key is present, it must be a string
            errors << ":verifier_api_key must be a string." if h[:verifier_api_key] && !h[:verifier_api_key].is_a?(String)

            # validation: if :email_fields is present, it must be an array of strings
            if h[:email_fields]
                if !h[:email_fields].is_a?(Array)
                    errors << "Invalid :email_fields: #{h[:email_fields].class}. Expected: Array."
                else
                    h[:email_fields].each { |field|
                        if !field.is_a?(String)
                            errors << "Invalid :email_fields: #{field.class}. Expected: String."
                        end
                    }
                end
            end

            # validation: if :phone_fields is present, it must be an array of strings
            if h[:phone_fields]
                if !h[:phone_fields].is_a?(Array)
                    errors << "Invalid :phone_fields: #{h[:phone_fields].class}. Expected: Array."
                else
                    h[:phone_fields].each { |field|
                        if !field.is_a?(String)
                            errors << "Invalid :phone_fields: #{field.class}. Expected: String."
                        end
                    }
                end
            end

            # validation: if :company_domain_fields is present, it must be an array of strings
            if h[:company_domain_fields]
                if !h[:company_domain_fields].is_a?(Array)
                    errors << "Invalid :company_domain_fields: #{h[:company_domain_fields].class}. Expected: Array."
                else
                    h[:company_domain_fields].each { |field|
                        if !field.is_a?(String)
                            errors << "Invalid :company_domain_fields: #{field.class}. Expected: String."
                        end
                    }
                end
            end

            # mapping
            @@indexes = h[:indexes] if h[:indexes]
            @@verifier_url = h[:verifier_url] if h[:verifier_url]
            @@verifier_api_key = h[:verifier_api_key] if h[:verifier_api_key]
            @@email_fields = h[:email_fields] if h[:email_fields]
            @@phone_fields = h[:phone_fields] if h[:phone_fields]
            @@company_domain_fields = h[:company_domain_fields] if h[:company_domain_fields]
        end

        # return true if the domain get any random address as valid
        def self.catch_all?(domain)
            BlackStack::Appending.verify("008e77980535470e848a4ca859a83db0@#{domain}")
        end

        # verify an email address using the AWS IP address of our website, wich is more reliable
        def self.verify(email)
            url = @@verifier_url
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
        def self.find_persons_with_full_name(name, cname)
            l = BlackStack::Appending.logger || BlackStack::DummyLogger.new

            l.logs "Guessing fname from #{name}... "
            fname = BlackStack::Appending::cleanup_fname(name)
            l.logf fname

            l.logs "Guessing lname from #{name}... "
            lname = BlackStack::Appending::cleanup_lname(name)
            l.logf lname

            BlackStack::Appending.find_persons(fname, lname, cname)
        end

        # Find a person in the indexes by its first name, last name and company name.
        # Append all the information in the index row.
        def self.find_persons(fname, lname, cname)
            l = BlackStack::Appending.logger || BlackStack::DummyLogger.new
            h = {
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
            BlackStack::Appending.indexes.each { |i|
                l.logs "Searching into #{i.name}... "
                ret = i.find([cname, fname, lname], false, nil)
                # add the name of the index in the last position of the match
                ret[:matches].each { |m| m.unshift(i.name.to_s) }
                # add matches to the list
                h[:matches] += ret[:matches]
                # sum the total files and the total enlapsed seconds                
                h[:enlapsed_seconds] += ret[:enlapsed_seconds]
                h[:files_processed] += ret[:files_processed]
                l.done
            }
            # update report
            @@report = h
            # return results
            h[:matches].map { |m| BlackStack::Appending::Result.new(m) }
        end

        # Find a company in the indexes by its first name, last name and company name.
        # Append all the information in the index row.
        def self.find_persons_by_company(cname)
            l = BlackStack::Appending.logger || BlackStack::DummyLogger.new
            h = {
                :matches => [],
                :enlapsed_seconds => 0,
                :files_processed => 0,
            }
            # looking for a record that matches with first name, last name and company name
            appends = []
            enlapsed_seconds = 0
            files_processed = 0
            BlackStack::Appending.indexes.each { |i|
                l.logs "Searching into #{i.name}... "
                ret = i.find([cname], true, nil)
                # add the name of the index in the last position of the match
                ret[:matches].each { |m| m.unshift(i.name.to_s) }
                # add matches to the list
                h[:matches] += ret[:matches]
                # sum the total files and the total enlapsed seconds                
                h[:enlapsed_seconds] += ret[:enlapsed_seconds]
                h[:files_processed] += ret[:files_processed]
                l.done
            }
            # update report
            @@report = h
            # return results
            h[:matches].map { |m| BlackStack::Appending::Result.new(m) }
        end

        # 
        class Result
            # array of values.
            # first 3 values are index name, key and row-number.
            attr_accessor :match
            
            def initialize(a)
                self.match = a
            end

            # From a given match (with the name of its index in the first position), get the value of a field by its name.
            def value(field)
                # get the index_name
                index_name = match[0]
                # get the index descriptor
                index = BlackStack::CSVIndexer.indexes.select { |i| i.name == index_name }.first
                # get position of the field into the hash descriptior
                k = index.mapping.to_a.map { |m| m[0].to_s }.index(field.to_s)
                # return nil if the field is not found
                return nil if k.nil?
                # get the field value
                match[k+3].to_s
            end

            # From a given match (with the name of its index in the first position), get the email addresses.
            def emails()
                keys = BlackStack::Appending.email_fields
                ret = []
                keys.each { |k|
                    v = self.value(k)
                    ret << v if v
                }
                ret
            end

            # From a given match (with the name of its index in the first position), get the phone numbers.
            def phones()
                keys = BlackStack::Appending.phone_fields
                ret = []
                keys.each { |k|
                    v = self.value(k)
                    ret << v if v
                }
                ret
            end

            # From a given match (with the name of its index in the first position), get the company domains.
            def company_domains()
                keys = BlackStack::Appending.company_domain_fields
                ret = []
                keys.each { |k|
                    v = self.value(k)
                    ret << v if v
                }
                ret
            end

        end # class Result

    end # Appending
end # BlackStack