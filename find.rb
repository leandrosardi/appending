require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

l = BlackStack::LocalLogger.new(DATA_PATH+'/logs/find.log')

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a searching of people.', 
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
    Dir.glob(source).each do |input_filename|
        # build output filename
        output_filename = input_filename.gsub('.csv', '.matches')
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
            input.each { |row|
                i += 1
                # get the full name
                name = row[0]
                fname = BlackStack::Appending::cleanup_fname(name)
                lname = BlackStack::Appending::cleanup_lname(name)
                # get the company name
                company = row[1]
                cname = BlackStack::Appending::cleanup_company(company)
                # log
                l.logs "#{i.to_s}. #{fname} #{lname} at #{cname}... "
                matches = []
                appends = []
                enlapsed_seconds = 0
                files_processed = 0
                BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /persona/ }.each { |i|
                    l.logs "Searching into #{i.name}..."
                    ret = i.find([company, fname, lname], false, nil)
                    # add name of thindex to the matches, in order to do a reverse-mapping later.
                    ret[:matches].each { |m| m << i.name }
                    # add matches to the list
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

                        # get the position of the emails inside the matches
                        p = [i.position_of(:email), i.position_of(:email1), i.position_of(:email2)]
                        q = i.position_of(:company_domain)
                        # verify emails
                        ret[:matches].each { |m|
                            #puts "Email: #{m[p[0]+2]}" if p[0]
                            appends << m[p[0]+2] if p[0] && BlackStack::Appending.verify(p[0])
                            appends << m[p[1]+2] if p[1] && BlackStack::Appending.verify(p[1])
                            appends << m[p[2]+2] if p[2] && BlackStack::Appending.verify(p[2])
                            if q 
                                domain = m[q+2]
                                appends += BlackStack::Appending.append(fname, lname, domain)
                            end
                        }
                    end
                    l.logf "#{ret[:matches].size} matches. #{appends.size} appends. #{ret[:files_processed].to_s} files processed. #{ret[:enlapsed_seconds]} seconds."
                }
                # log the results
                total_leads_matches += 1 if matches.length > 0
                # increase the counter of appeneds
                total_leads_appends += 1 if appends.size > 0
                # calculate rates
                match_rate = ((total_leads_matches.to_f / i.to_f).to_f * 100.to_f).ceil.to_i
                appends_rate = ((total_leads_appends.to_f / i.to_f).to_f * 100.to_f).ceil.to_i
                #l.logf "Found #{matches.size} matches in #{files_processed.to_s}, in #{enlapsed_seconds} seconds."
                l.logf "#{matches.size.to_s} matches. #{appends.size.to_s} appends. (#{match_rate}% #{appends_rate}%)"
            }
            # close the files
            input.close
            output.close
#        end
    end
}
l.done