require 'csv'
require 'email_verifier'
require 'nokogiri'

module BlackStack
    module Appending

        module Parser
            # parse search pages from sales navigator
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
            company = company.split(/ at /).last
            company.gsub!(/LLC/, '')
            company.gsub!(/Inc/, '')
            company.gsub!(/\(\d\d\d\d - Present\)/, '')
            company.strip! # remove leading and trailing spaces
            company.gsub!(/\.$/, '')  
            company.gsub!(/\,$/, '') 
            company.gsub!(/[^a-zA-Z0-9,\.\-\s]/, '') # remove extra spaces
            company.strip! # remove leading and trailing spaces
            company
        end

        def self.find(search, l=nil)
            ret = {
                :matches => [],
            }

            # get the logger
            l = BlackStack::DummyLogger.new if l.nil?

            # build search key
            search[:key] = "#{search[:cname]}#{search[:fname]}#{search[:lname]}".upcase

            # define the source
            source = "/home/leandro/node01/extern/zi/*.index01" # the files to be imported

            # start time
            start_time = Time.now

            # totals
            total_lines = 0
            total_matches = 0

            # searching in the indexed files
        #    l.log "Search term: #{search.to_s}"
            files = Dir.glob(source)
            n = 0 
            files.each do |file|
                # get the name of the file from the full path
                name = file.split('/').last
                # get the path of the file from the full path
                path = file.gsub("/#{name}", '')
                # opening log line
        #        l.logs "Searching #{name}... "
                # setting boundaries for the binary search
                i = 0
                lines = file==files.last ? `wc -l #{file}`.split(' ').first.to_i : 500000
                max = `wc -c #{file}`.split(' ').first.to_i
                middle = ((i + max) / 2).to_i
                # totals
                total_lines += lines
                # open file with random access
                f = File.open(file, 'r')
                # remember middle variable from the previous iteration
                prev = -1
                # binary search
                while i<max
                    # get the middle of the file
                    middle = ((i + max) / 2).to_i
                    # break if the middle is the same as the previous iteration
                    break if middle==prev
                    # remember the middle in this iteration
                    prev = middle
                    # opening log line
            #        l.logs "#{middle}... "
                    # go to the middle of the file
                    f.seek(middle)
                    # read the line
                    # the cursor is at the middle of a line
                    # so, I have to read a second line to get a full line
                    line = f.readline 
                    # most probably I landed in the midle of a line, so I have to get the size of the line where I landed.
                    a = line.split('","')
                    while a.size < 2 # this saves the situation when the cursor is inside the last field where I place the size of the line
                        middle -= 1
                        f.seek(middle)
                        line = f.readline
                        a = line.split('","')
                    end
                    line_size = a.last.gsub('"', '').to_i
                    middle -= line_size-line.size+1
                    # seek and readline again, to get the line from its begining
                    f.seek(middle)
                    line = f.readline
                    # strip the line
                    line.strip!
                    # get the first field of the CSV line
                    fields = CSV.parse_line(line)
                    cname = fields[0]
                    fname = fields[1]
                    lname = fields[2]
                    key = cname.upcase+fname.upcase+lname.upcase
                    # compare the first field with the search term
                    if cname =~ /^#{Regexp.escape(search[:cname])}.*/i && fname =~ /#{Regexp.escape(search[:fname])}/i && lname =~ /#{Regexp.escape(search[:lname])}/i
                    #if key == search[:key]
                        # found
            #            l.logf "found (#{cname},#{fname},#{lname})"
                        ret[:matches] << fields.dup
                        total_matches += 1
                        break
                    else
                        # not found
                        if key < search[:key]
                            # search in the down half
                            i = middle
                        else
                            # search in the up half
                            max = middle
                        end
            #            l.logf "not found (#{cname},#{fname},#{lname})"
                    end
                end
                # closing the file
                f.close
                # closing the log line
        #        l.done
                # increment file counter
                n += 1
                # TODO: remove this
                #break if n>=215
            end

            end_time = Time.now

            ret[:enlapsed_seconds] = end_time - start_time
            ret[:lines_processed] = total_lines
            ret[:lines_matched] = total_matches

            ret
        end
    end # Appending
end # BlackStack