require 'active_support/all'
require 'icalendar'
require 'open-uri'
require 'json'
require 'nokogiri'

class TouchstoneServerError < StandardError
end

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
    beginning_of_month = Date.today.beginning_of_month
    end_of_month = Date.today.end_of_month
    
    "/#{gym_name}/calendar/events?format=raw&ids=#{calendar_codes}&date-start=#{beginning_of_month.to_time.to_i}&date-end=#{end_of_month.to_time.to_i}&_=1406859918932&limit=0"
  end

  def response_json
    uri = URI.parse("http://#{HOST}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 9

    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    
    if response.body.include?("Error displaying the error page: Application Instantiation Error")
      raise TouchstoneServerError, response.body
    end

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

