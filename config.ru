require 'rack'
require 'active_support/all'
require 'icalendar'
require 'json'
require 'nokogiri'

class TouchstoneCal
  HOST = "touchstoneclimbing.com"
 
  def initialize(env)
    @env = env
  end

  def gym_name
    if @env['QUERY_STRING'].include?("ironworks")
      "ironworks"
    elsif @env['QUERY_STRING'].include?("gwpc") || @env['QUERY_STRING'].include?("gwpower-co")
      "gwpower-co"
    end
  end

  def path
    three_months_ago = 3.months.ago
    three_months_from_now = 3.months.from_now
    
    start_time = three_months_ago.beginning_of_month.to_i
    end_time = three_months_from_now.beginning_of_month.to_i
    
    "/#{gym_name}/calendar/events?format=raw&ids=gc-20&date-start=#{start_time}&date-end=#{end_time}&_=1406859918932&limit=0"
  end

  def response_json
    response = Net::HTTP.get_response(HOST, path)
    JSON.parse(response.body)
  end

  def calendar 
    cal = Icalendar::Calendar.new
    
    response_json.each do |event|
      description = event["description"].split("<br/>")[1]
      cal.event do |e|
        e.dtstart = DateTime.parse(event["start"])
        e.dtend = DateTime.parse(event["end"])
        e.summary = Nokogiri::HTML(event["title"].gsub('<br />',"\n")).text
        e.description = Nokogiri::HTML(description).text
        e.url = "http://#{HOSt}#{event["url"]}"
      end
    end
  
    cal
  end

  def response
    [200, {}, calendar.to_ical]
  end
end
    
class TouchstoneCalApp
  def self.call(env)
    TouchstoneCal.new(env).response
  end
end

run TouchstoneCalApp
