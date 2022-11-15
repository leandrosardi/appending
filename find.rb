require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

l = BlackStack::LocalLogger.new('./logs/find.log')


# rename the HMTL files, removing the 'page ' prefix added when downloading
l.logs 'Searching...'
@searches.each { |search_name|
    # roll back ingested files as not ingested
    source = "./searches/#{search_name}.csv" # the files to be imported
    # ingest the bites
    Dir.glob(source).each do |input_filename|
        # build output filename
        output_filename = input_filename.gsub('.csv', '.matches')
        # validate the file does not exist
#        if File.exists?(output_filename)
#            l.logf "File #{output_filename} already exists."
#        else
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
                enlapsed_seconds = 0
                files_processed = 0
                BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /ix\.persona/ }.each { |i|
                    #l.logs "Searching into #{i.name}..."
                    ret = i.find([company, fname, lname], false, nil)
                    matches += ret[:matches]
                    enlapsed_seconds += ret[:enlapsed_seconds]
                    files_processed += ret[:files_processed]
                    # if there is matches, write them into the output file
                    if ret[:matches].length > 0
                        ret[:matches].each { |m| 
                            line = "\"#{m.join('","')}\""
                            output.puts line
                        }
                        output.flush
                    end
                    #l.logf "#{ret[:matches].to_s}. #{ret[:files_processed].to_s} files processed. #{ret[:enlapsed_seconds]} seconds."
                }
                l.logf "Found #{matches.size} matches in #{files_processed.to_s}, in #{enlapsed_seconds} seconds."
            }
            # close the files
            input.close
            output.close
#        end
    end
}
l.done