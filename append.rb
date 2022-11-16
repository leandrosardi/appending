require_relative '../csv-indexer/lib/csv-indexer'
require 'simple_command_line_parser'
require_relative './config'
require_relative './appending'

l = BlackStack::LocalLogger.new(DATA_PATH+'/logs/append.log')


l.logs 'Appending...'
@searches.each { |search_name|
    # roll back ingested files as not ingested
    source = "#{DATA_PATH}/searches/#{search_name}.matches" # the files to be imported
    # ingest the bites
    Dir.glob(source).each do |input_filename|
        # build output filename
        output_filename = input_filename.gsub('.matches', '.appends')
        # validate the file does not exist
#        if File.exists?(output_filename)
#            l.logf "File #{output_filename} already exists."
#        else
            # stats initialization
            total_leads_appended = 0
            # open CSV file
            input = CSV.open(input_filename, 'r')
            # open CSV file
            output = File.open(output_filename, 'w')
            # iterate through each row
            i = 0
            input.each { |row|
                i += 1
                fname = row[2]
                lname = row[3]
                email = row[4]
                title = row[5]
                cname = row[11]
                domain = row[12]
                # TODOL add lead information: title, location, linkedin url, facebook url, twitter url, etc.
                # TODO: add company information: size, industry, revenue, linkedin url, facebook url, twitter url, etc.
                valid_emails = []
                valid_emails = email if 
            }
            # close the files
            input.close
            output.close
#        end
    end
}
l.done