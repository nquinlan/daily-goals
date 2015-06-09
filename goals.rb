require "google_drive"
require "erb"
require "json"
require "faraday"

# Get a Google Access Token from an OAuth Refresh token
response = Faraday.post do |req|
  req.url "https://www.googleapis.com/oauth2/v3/token"
  req.body = {
    "refresh_token" => params['google_refresh_token'],
    "client_id" => params['google_client_id'],
    "client_secret" => params['google_client_secret'],
    "grant_type" => "refresh_token"
  }
end

token_info = JSON.parse(response.body)
access_token = token_info["access_token"]

# login to Google Drive
session = GoogleDrive.login_with_oauth(access_token)
# let's go ahead and grab the spreadsheet that has all of my goals
spread = session.spreadsheet_by_key(params['spreadsheet_key'])
# now we're gonna assume the first worksheet is the one we care about
sheet = spread.worksheets.first

# get the number of rows in each column (so that we may choose a random one)
# this code is a little confusing, and made my head hurt
max_row_index_by_column = []

# iterate through each row, getting all the cell values
sheet.rows.each_with_index do |row, row_index|
  # iterate through each cell value
  row.each_with_index do |column, column_index|
    if max_row_index_by_column[column_index].nil?
      # if the row is empty or it's the last row in the sheet
      # (and the column hasn't ended earlier)
      if column == ""
        # if the cell (column) is empty we'll assume the previous cell was
        # the final
        max_row_index_by_column[column_index] = row_index
      elsif row_index == sheet.num_rows - 1
        # if the cell is the last row of the sheet, then it must be the final
        max_row_index_by_column[column_index] = row_index + 1
      end
    end
  end
end

# select a random goal for each column
goals = []
for column_number in 1..sheet.num_cols
  # pick a random row index for the column
  # then add two to it
  #   - one to make it a number, rather than an index
  #   - one to adjust to rand()'s functionality
  row_number = 2 + rand(max_row_index_by_column[column_number - 1] - 1)
  # throw it into an array, as a hash
  goals[column_number - 1] = { :type => sheet[1, column_number], :goal => sheet[row_number, column_number] }
end

# the current time for templating
time = Time.new
today = time.strftime("%Y-%m-%d")

# the spreadsheet's url again for the template 
sheet_url = spread.human_url()

# let's go ahead and grab the template (big ups to ZURB for it)
template = ERB.new File.new("email.erb").read, nil, "%"
# then we throw our values into it
body = template.result(binding)

# let's send it off with SendGrid!
# we're just using a POST request, 'cause we can
# however, there's a bunch of awesome client libraries that'll do it for us
# http://sendgrid.com/docs/Integrate/libraries.html

response = Faraday.post do |req|
  req.url "https://api.sendgrid.com/api/mail.send.json"
  req.body = {
    "api_user" => params['sendgrid_username'],
    "api_key" => params['sendgrid_password'],
    "to" => params['email'],
    "from" => params['email'],
    "subject" => "Daily Goals for #{today}",
    "html" => body
  }
end