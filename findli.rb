require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

l = BlackStack::LocalLogger.new(DATA_PATH+'/logs/findli.log')

# 
parser = BlackStack::SimpleCommandLineParser.new(
  :description => 'This command will launch a searching of people.', 
  :configuration => [{
    :name=>'url', 
    :mandatory=>true, 
    :description=>'Url of the Linkedin user you are looking for.', 
    :type=>BlackStack::SimpleCommandLineParser::STRING,
  }]
)

# getting the searches to process
url = parser.value('url')

                # log
                l.logs "#{url}... "
                matches = []
                enlapsed_seconds = 0
                files_processed = 0
                total_leads_matches = 0
                BlackStack::CSVIndexer.indexes.select { |i| i.name =~ /linkedin_url/ }.each { |i|
                    l.logs "Searching into #{i.name}..."
                    ret = i.find(url, false, nil)
                    matches += ret[:matches]
                    enlapsed_seconds += ret[:enlapsed_seconds]
                    files_processed += ret[:files_processed]
=begin
                    # if there is matches, write them into the output file
                    if ret[:matches].length > 0
                        ret[:matches].each { |m| 
                            line = "\"#{i.name}\",\"#{m.join('","')}\""
                            output.puts line
                        }
                        output.flush
                    end
=end
                    l.logf ret[:matches].to_s #logf "#{ret[:matches].to_s}. #{ret[:files_processed].to_s} files processed. #{ret[:enlapsed_seconds]} seconds."
                }
                # log the results
                total_leads_matches += 1 if matches.length > 0
                #l.logf "Found #{matches.size} matches in #{files_processed.to_s}, in #{enlapsed_seconds} seconds."
                l.logf "done\n#{matches.size.to_s} matches found.\n#{files_processed.to_s} files processed.\n#{enlapsed_seconds} seconds."
