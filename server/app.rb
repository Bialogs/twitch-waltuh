# frozen_string_literal: true

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :public_folder, proc { File.join(File.expand_path(__dir__), 'public') }
set :port, 4567
set :bind, proc { ENV['development'] ? 'localhost' : '0.0.0.0' }

if ENV['TW_TLS_ENABLED']
  MyApp.run! do |server|
    ssl_options = {
      cert_chain_file: ENV['TW_SERVER_CHAIN_PATH'],
      private_key_file: ENV['TW_SERVER_KEY_PATH'],
      verify_peer: false
    }
    server.ssl = true
    server.ssl_options = ssl_options
  end
end

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end

      ws.onmessage do |msg|
        EM.next_tick { settings.sockets.each { |s| s.send(msg) } }
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
