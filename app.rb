require 'sinatra'
require 'twilio-ruby'

class EbtBalanceSmsApp < Sinatra::Base
  TWILIO_CLIENT = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH'])

  post '/' do
    puts request
    puts request.path_info
    @texter_phone_number = params["From"]#.match(/[\d+]/)[0]
    puts @texter_phone_number
    @debit_number = DebitCardNumber.new(params["Body"])
    @twiml_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/get_balance_v2?phone_number=#{@texter_phone_number}"
    puts @debit_number.to_s
    if @debit_number.is_valid?
      call = TWILIO_CLIENT.account.calls.create( \
        url: @twiml_url, \
        to: "+18773289677", \
        send_digits: "ww1ww#{@debit_number.to_s}", \
        from: ENV['TWILIO_NUMBER'], \
        record: "true", \
        method: "GET" \
      )
    end
  end

  get '/get_balance_v2' do
    puts params
    @my_response = Twilio::TwiML::Response.new do |r|
      r.Record :transcribeCallback => "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/#{params[:phone_number]}/send_balance" #:transcribe => true
    end
    puts @my_response.text
    @my_response.text
  end

=begin
  post '/get_balance_v2' do
    puts params
    TWILIO_CLIENT.account.messages.create( \
      to: params[:phone_number].strip, \
      from: ENV['TWILIO_NUMBER'], \
      body: params["TranscriptionText"][1..140] \
    )
  end
=end

  post '/:phone_number/send_balance' do
    puts params
    TWILIO_CLIENT.account.messages.create( \
      to: params[:phone_number].strip, \
      from: ENV['TWILIO_NUMBER'], \
      body: params["TranscriptionText"][1..140] \
    )
  end
end

class DebitCardNumber
  attr_accessor :number

  def initialize(number)
    @number = number
  end

  def to_s
    @number
  end

  def is_valid?
    return true
  end
end
