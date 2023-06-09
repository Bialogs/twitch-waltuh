# frozen_string_literal: true

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :public_folder, proc { File.join(File.expand_path(__dir__), 'public') }
set :port, 4567
set :bind, proc { ENV['development'] ? 'localhost' : '0.0.0.0' }

if ENV.fetch('TW_TLS_ENABLED', false)
  # Set SSL Settings on the Thin server and configure Sinatra server
  # settings with the correct certificates and Thin server.
  class MyThinBackend < ::Thin::Backends::TcpServer
    def initialize(host, port, options)
      super(host, port)
      @ssl = true
      @ssl_options = options
    end
  end

  configure do
    class << settings
      def server_settings
        {
          backend: MyThinBackend,
          private_key_file: ENV['TW_SERVER_KEY_PATH'],
          cert_chain_file: ENV['TW_SERVER_CHAIN_PATH'],
          verify_peer: false
        }
      end
    end
  end
end

get '/' do
  if !request.websocket?
    @tls = ENV.fetch('TW_TLS_ENABLED', false)
    @alternate_user = ENV.fetch('TW_ALTERNATE_USER', "''")
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

get '/waltuh' do
  send_file File.join(settings.public_folder, 'waltuh.mp3')
end

get '/97' do
  send_file File.join(settings.public_folder, '97.mp3')
end

get '/jesse' do
  send_file File.join(settings.public_folder, 'jesse.mp3')
end

get '/cancer' do
  send_file File.join(settings.public_folder, 'cancer.mp3')
end

get '/tumagerkin' do
  send_file File.join(settings.public_folder, 'tumagerkin.mp3')
end

get '/oklg' do
  send_file File.join(settings.public_folder, 'oklg.mp3')
end

get '/can_opening' do
  send_file File.join(settings.public_folder, 'can_opening.mp3')
end

get '/hutlaw' do
  send_file File.join(settings.public_folder, 'hutlaw.mp3')
end

get '/bark' do
  send_file File.join(settings.public_folder, 'bark.mp3')
end

get '/hello' do
  send_file File.join(settings.public_folder, 'hello.mp3')
end

get '/favicon.ico' do
  send_file File.join(settings.public_folder, 'favicon.ico')
end
