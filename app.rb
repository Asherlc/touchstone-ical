require 'sinatra'
require './touchstone_cal'

error Net::ReadTimeout do
  "The Touchstone server timed out. Sorry."
end

error TouchstoneServerError do
  "The Touchstone server crapped out. Sorry."
end

get '/:gym/:class_type' do
  TouchstoneCal.new(params[:gym], params[:class_type]).to_ical
end
