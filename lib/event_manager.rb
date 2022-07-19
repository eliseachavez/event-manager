require 'csv'

def clean_zipcode(zipcode)
  if zipcode.nil?
    zipcode = '00000'
  elsif zipcode.length > 5
    zipcode.truncate(5)
  elsif zipcode.length < 5
    until zipcode.length == 5
      zipcode = "0"+zipcode
    end
  end
  zipcode
end


puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])


  puts "#{name} #{zipcode}"
end


