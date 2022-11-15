require 'csv'
require 'email_verifier'
require 'nokogiri'

module BlackStack
    module Appending
        # This class is used to parse the HTML files downloaded from Sales Navigator and other sources.
        module Parser
            # parse search results pages from sales navigator, and save the company name and full name into a CSV file
            def self.parse_sales_navigator_result_pages(search_name, l=nil)
                # create logger if not passed
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # define output filename
                output_file = "./searches/#{search_name}.csv" # the output file
                raise 'Output file already exists.' if File.exists?(output_file)
                output = File.open(output_file, 'w')
                # parse
                i = 0
                source = "./searches/#{search_name}/*.html" # the files to be imported
                Dir.glob(source).each do |file|
                    doc = Nokogiri::HTML(open(file))
                    lis = doc.xpath('//li[contains(@class, "artdeco-list__item")]')    
                    lis.each { |li|
                        i += 1
                        doc2 = Nokogiri::HTML(li.inner_html)
                        n1 = doc2.xpath('//div[contains(@class,"artdeco-entity-lockup__title")]/a/span').first
                        n2 = doc2.xpath('//div[contains(@class,"artdeco-entity-lockup__subtitle")]/a').first
                        line = []
                        line << "\"#{n1.text.strip.gsub('"', '')}\"" if !n1.nil?
                        line << "\"#{n2.text.strip.gsub('"', '')}\"" if !n2.nil?
                        l.logs "#{i.to_s}, #{line.join(',')}"
                        output.puts line.join(',')
                        output.flush
                        l.done
                    }    
                end    
                # close output file    
                output.close
            end # def self.parse_sales_navigator_result_pages(search_name)
        end # module Parser

        # return true if the domain get any random address as valid
        def self.catch_all?(domain)
            EmailVerifier.config do |config|
                config.verifier_email = "leandro.sardi@expandedventure.com"
            end
            EmailVerifier.check("008e77980535470e848a4ca859a83db0@#{domain}")
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

        def self.cleanup_fname(name)
            return '' if name.nil?
            a = name.split(/[^a-zA-Z]/)
            a.size > 0 ? a[0] : ''
        end

        def self.cleanup_lname(name)
            return '' if name.nil?
            a = name.split(/[^a-zA-Z]/)
            a.size > 1 ? a[1] : ''
        end

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
                break if word.size >= 5 || ret.split(' ').size > 2
            } 
            ret.strip!
            # return
            ret
        end
    end # Appending
end # BlackStack