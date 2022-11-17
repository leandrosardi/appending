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
        if File.exists?(output_filename)
            l.logf "File #{output_filename} already exists."
        else
            # stats initialization
            total_leads_matches = 0
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
                BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /persona/ }.each { |i|
                    #l.logs "Searching into #{i.name}..."
                    ret = i.find([company, fname, lname], false, nil)
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
                match_rate = ((total_leads_matches.to_f / i.to_f).to_f * 100.to_f).ceil.to_i
                #l.logf "Found #{matches.size} matches in #{files_processed.to_s}, in #{enlapsed_seconds} seconds."
                l.logf "#{matches.size.to_s} (#{match_rate}%)"
            }
            # close the files
            input.close
            output.close
        end
    end
}
l.done