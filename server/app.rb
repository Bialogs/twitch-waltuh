# frozen_string_literal: true

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :public_folder, 'public'
set :port, 4567

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end

      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each { |s| s.send(msg)}}
      end

      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
end

get '/sound' do
  send_file File.join(settings.public_folder, 'waltuh.mp3')
end
