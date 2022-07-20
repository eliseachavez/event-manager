require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,'0')[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your rep by visiting www.commoncause.org'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone_num)
  phone_num.gsub!(/[^0-9]/, '') # remove () and - characters and . or just remove any non digit character

  if phone_num.length == 10
    phone_num
  elsif phone_num.length > 10
    if phone_num[0].to_i == 1
      phone_num[1..phone_num.length+1]
    else
      "This is not a valid phone number"
    end
  else
    "This is not a valid phone number"
  end
end

def get_date_and_time_array(regdate)
  # split into date and time
  regdate = regdate.split(" ")

  begin
    # ["11/12/08", "10:47"]
    date = Date.strptime(regdate[0], '%m/%d/%y')
  rescue ArgumentError=>e
    puts "Not able to convert to a date"
  end

  begin
    time = Time.parse(regdate[1])
  rescue ArgumentError=>e
    puts "Not able to convert to a time"
  end

  date_time = []
  date_time.push(date)
  date_time.push(time)
end

def inc_peak_hour(date_time, peak_hours)
  time = date_time[1]
  time = time.hour # turn time into an integer
  peak_hours[time] += 1
end

def inc_peak_day(date_time, peak_days)
  day = date_time[0].strftime('%A')
  peak_days[day.to_sym] += 1
end

def determine_peak_hour(peak_hours)
  peak_hour = peak_hours.max_by{|k,v| v}
  Time.strptime(peak_hour[0].to_s, '%H').strftime('%l:%M')
end

def determine_peak_day(peak_days)
  peak_day = peak_days.max_by{|k,v| v}
  peak_day[0].to_s
end

def determine_best_day_and_hour_for_ads(peak_hours, peak_days)
  peak_hour = determine_peak_hour(peak_hours)
  peak_day = determine_peak_day(peak_days)
  puts "Best time to display ads would be on #{peak_day} at #{peak_hour}"
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read("form_letter.erb")
erb_template = ERB.new template_letter

peak_hours = {0=>0,1=>0,2=>0,3=>0,4=>0,5=>0,
6=>0,7=>0,8=>0,9=>0,10=>0,11=>0,12=>0,
13=>0,14=>0,15=>0,16=>0,17=>0,18=>0,
19=>0,20=>0,21=>0,22=>0,23=>0}
peak_days = {Sunday:0,Monday:0,Tuesday:0,Wednesday:0,Thursday:0,Friday:0,Saturday:0}


contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_num = clean_phone_number(row[:homephone])
  date_time_arr = get_date_and_time_array(row[:regdate])
  inc_peak_hour(date_time_arr, peak_hours)
  inc_peak_day(date_time_arr, peak_days)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end

determine_best_day_and_hour_for_ads(peak_hours, peak_days)
