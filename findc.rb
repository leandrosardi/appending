require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

=begin
email='charles.cathey.p2tm@statefarm.com'
EmailVerifier.config do |config|
    config.verifier_email = "leandro.sardi@expandedventure.com"
end
puts EmailVerifier.check(email)
exit(0)
=end

l = BlackStack::LocalLogger.new(DATA_PATH+'/logs/find.log')

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a searching of companies by name.', 
  :configuration => [{
    :name=>'search', 
    :mandatory=>false, 
    :description=>'Name of the serch. Use `all` for run all searches. Default: `all`.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
    :default => 'all',
  }]
)

# getting the searches to process
a = parser.value('search') == 'all' ? @searches : @searches.select { |s| s == parser.value('search') }

# find matches in the index persona.us.09
l.logs 'Searching...'
a.each { |search_name|
    # roll back ingested files as not ingested
    source = "#{DATA_PATH}/searches/#{search_name}.csv" # the files to be imported
    # ingest the bites
a = 0
b = 0    
    Dir.glob(source).each do |input_filename|
        # build output filename
        output_filename = input_filename.gsub('.csv', '.matches0')
        # validate the file does not exist
#        if File.exists?(output_filename)
#            l.logf "File #{output_filename} already exists."
#        else
            # stats initialization
            total_leads_matches = 0
            total_leads_appends = 0
            # open CSV file
            input = CSV.open(input_filename, 'r')
            # open CSV file
            output = File.open(output_filename, 'w')
            # iterate through each row
            i = 0
            j = 0
            input.each { |row|
                i += 1
                # get the full name
                name = row[0]
                fname = BlackStack::Appending::cleanup_fname(name)
                lname = BlackStack::Appending::cleanup_lname(name)
                # get the company name
                company = row[1]
                cname = company #BlackStack::Appending::cleanup_company(company)
                # log
                l.logs "#{i.to_s}. #{fname} #{lname} at #{cname}... "
                #l.logs "#{i.to_s}. #{row}... "
                matches = []
                enlapsed_seconds = 0
                files_processed = 0
                if company.to_s.size == 0
                    l.logf "No company name."
                    a += 1
                else
                    j += 1
                    b += 1
                    BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /persona/ }.each { |i|
                        #l.logs "Searching into #{i.name}..."
                        ret = i.find([cname], true, nil)
                        # add name of thindex to the matches, in order to do a reverse-mapping later.
                        ret[:matches].each { |m| m << i.name }
                        # add to the list of matches
                        matches += ret[:matches]
                        enlapsed_seconds += ret[:enlapsed_seconds]
                        files_processed += ret[:files_processed]
                        # if there is matches, write them into the output file
                        if ret[:matches].length > 0
                            ret[:matches].each { |m| 
                                line = "\"#{i.name}\",\"#{m.join('","')}\""
                                output.puts line
                            }
                            output.flush
                        end
                        #l.logf "#{ret[:matches].to_s}. #{ret[:files_processed].to_s} files processed. #{ret[:enlapsed_seconds]} seconds."
                    }
                    # log the results
                    total_leads_matches += 1 if matches.length > 0

                    match_rate = ((total_leads_matches.to_f / i.to_f).to_f * 100.to_f).ceil.to_i # total match conversion 
                    #match_rate = ((total_leads_matches.to_f / j.to_f).to_f * 100.to_f).ceil.to_i # effective match conversion

                    if matches.size==0
                        #l.logf "Found #{matches.size} matches in #{files_processed.to_s}, in #{enlapsed_seconds} seconds."
                        l.logf "#{matches.size.to_s} (#{match_rate}%)"
                    else
                        domains = matches.map { |m|
                            # get the name of the index
                            index_name = m.last
                            # get the index descriptor
                            index = BlackStack::CSVIndexer.indexes.select { |i| i.name == index_name }.first
                            # get position of the company domain into the hash descriptior
                            k = index.mapping.to_a.map { |m| m[0].to_s }.index('company_domain')
                            # get the company domain
                            domain = m[k+2].to_s
                            # normalize the domain
                            domain.to_s.gsub('www.', '').downcase
                        }.uniq
                        # run email apending
                        emails = []
                        domains.each { |domain|
#print '.'
#                            l.logs "Appending emails for #{fname}, #{lname}, #{domain}..."
                            begin
#binding.pry
                                appends = BlackStack::Appending.append(fname, lname, domain) 
                                emails += appends
#                                l.logf appends.size.to_s
                                break if emails.size>0
                            rescue Exception => e
#                                l.logf "Error: #{e.message}"
                            end
                        }
                        total_leads_appends += 1 if emails.length > 0
                        # log
                        append_rate = ((total_leads_appends.to_f / i.to_f).to_f * 100.to_f).ceil.to_i # total match conversion 
                        l.logf "#{domains.size.to_s} domains, #{emails.size.to_s} emails (#{match_rate}%, #{append_rate}%)."
                    end # if matches.size>0
                end # if company.to_s.size > 0
            }
            # close the files
            input.close
            output.close
l.logf "#{a.to_s}/#{b.to_s} have company name."
break
#        end
    end
}
l.done