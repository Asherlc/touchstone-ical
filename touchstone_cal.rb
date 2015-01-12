require 'active_support/all'
require 'icalendar'
require 'json'
require 'nokogiri'

class TouchstoneCal
  HOST = "touchstoneclimbing.com"

  CLASS_CODES = {
    "gwpower-co" => {
      "kids" => 16,
      "fitness" => 17,
      "core-and-stretch" => 18,
      "crossfit" => 19,
      "yoga" => 20,
      "special-events" => 43
    },
    "ironworks" => {
      "core" => 21,
      "boxing" => 22,
      "clinics-and-events" => 23,
      "cycling" => 24,
      "total-body-conditioning" => 25,
      "yoga" => 26
    }
  }
 
  def initialize(gym, class_type)
    @gym = gym
    @class_type = class_type
  end

  def gym_name
    if @gym == "ironworks"
      "ironworks"
    elsif @gym = "gwpc" || @gym = "gwpower-co"
      "gwpower-co"
    end
  end

  def calendar_codes
    if @class_type == "all"
      CLASS_CODES[gym_name].values.collect{ |code| "gc-#{code}" }.join("%2C")
    else
      "gc-#{CLASS_CODES[gym_name][@class_type]}"
    end
  end

  def path
    one_month_ago = 1.months.ago
    one_month_from_now = 1.months.from_now
    
    start_time = one_month_ago.beginning_of_month.to_i
    end_time = one_month_from_now.beginning_of_month.to_i
    
    "/#{gym_name}/calendar/events?format=raw&ids=#{calendar_codes}&date-start=#{start_time}&date-end=#{end_time}&_=1406859918932&limit=0"
  end

  def response_json
    puts HOST, path
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
        e.url = "http://#{HOST}#{event["url"]}"
      end
    end
  
    cal
  end

  def to_ical
    calendar.to_ical
  end
end

