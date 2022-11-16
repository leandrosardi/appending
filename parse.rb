require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

l = BlackStack::LocalLogger.new(DATA_PATH+'/logs/parse.log')

# rename the HMTL files, removing the 'page ' prefix added when downloading
l.logs 'Renaming HTML files...'
@searches.each { |search_name|
    # roll back ingested files as not ingested
    source = "#{DATA_PATH}/searches/#{search_name}/page*.html" # the files to be imported
    # ingest the bites
    Dir.glob(source).each do |file|
        # get the name of the file from the full path
        name = file.split('/').last
        # rollingback the file
        l.logs "Renaming #{name}... "
        File.rename(file, file.gsub('page ', ''))
        l.done
    end
}
l.done

l.logs 'Parsing HTML files...'
@searches.each { |search_name|
    l.logs "Folder #{search_name}... "
    begin
        BlackStack::Appending::Parser.parse_sales_navigator_result_pages(search_name, nil)
        l.done
    rescue => e
        l.logf e.message
    end
}
l.done

exit(0)
