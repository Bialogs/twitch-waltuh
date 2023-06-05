# frozen_string_literal: true

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :public_folder, proc { File.join(File.expand_path(__dir__), 'public') }
set :port, 4567
set :bind, proc { ENV['development'] ? 'localhost' : '0.0.0.0' }

if ENV['TW_TLS_ENABLED']
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
