require 'rack'
require 'active_support/all'
require 'icalendar'
require 'json'
require 'nokogiri'

three_months_ago = 3.months.ago
three_months_from_now = 3.months.from_now

start_time = three_months_ago.beginning_of_month.to_i
end_time = three_months_from_now.beginning_of_month.to_i

host = "touchstoneclimbing.com"
path = "/gwpower-co/calendar/jsonfeed?format=raw&gcid=20&start=#{start_time}&end=#{end_time}&_=1406859918932"

response = Net::HTTP.get_response(host, path)
json = JSON.parse(response.body)
# 
# cal = Icalendar::Calendar.new
# 
# json.each do |event|
#   description = event["description"].split("<br/>")[1]
#   cal.event do |e|
#     e.dtstart = DateTime.parse(event["start"])
#     e.dtend = DateTime.parse(event["end"])
#     e.summary = Nokogiri::HTML(event["title"].gsub('<br />',"\n")).text
#     e.description = Nokogiri::HTML(description).text
#     e.url = "http://#{host}#{event["url"]}"
#   end
# end
# 
# 
# headers = {
#   "Content-Type" => "text/html"
# }

status = 200
run lambda { |env| [200, {}, ["foo"]] }
