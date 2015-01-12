require 'sinatra'
require './touchstone_cal'

get '/:gym/:class_type' do
  TouchstoneCal.new(params[:gym], params[:class_type]).to_ical
end
