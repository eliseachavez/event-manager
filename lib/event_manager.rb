require 'csv'
puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]
  zipcode = row[:zipcode]
  zipcode = zipcode.to_s
  if zipcode.length > 5
    zipcode.truncate(5)
  elsif zipcode.length < 5
    # add 0s until it IS five
    until zipcode.length == 5
      zipcode = "0"+zipcode
    end
  end
  # if zipcode is 5 digits, assume it is correct

  # if zipcode is more than 5 digits, truncate to first five digits

  # if zipcode is less than 5 digits, add zeroes to the front until it is 5


  puts "#{name} #{zipcode}"
end
