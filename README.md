Tw is a combination Sinatra and Twitch Chat bot that analyzes chat messages in real time for an order of words. When the order of words is found, the chat bot sends an async websocket request to the Sinatra server, which will forward it to all connected clients, and those clients will play the mp3. Tw can also run in local mode, without a Sinatra server. The local mode will play the sound over default audio device using an async event.

### Design

Tw is based on the same architecture as my `tsc` project. The main addition is the Sinatra server so that users do not have to spend time setting up WSL or Ruby for Windows. Secondarily, Tw uses the `EventMachine#defer` pattern to background I/O tasks such as playing the audio or sending additional websocket requests to the media server in server mode as well as offloading logic for calculating if events have been triggered.

The main `tw.rb` module sets up `Handlers`, `Conf`, and the websocket connection. It then enters into the main `EventMachine` loop where on new websocket messages a sound event handler is started via `EM#defer`. To add new triggers for sounds, create a new handler with callbacks expected by `EM#defer` and add an entry into the list `on :message`. In the implementation of a handler it is important to use a `Mutex` to synchronize access to buffers and shared state since the trigger logic can run in different EventMachine threads at once.

### Installation

Install Ruby 3.2 and then `bundle install` and then `gem install foreman`.

### Configuration

#### Chatbot configuration

Wordlist is contained in `lib/tw/conf/words.txt`. Words must be separated by newline.

VIP wordlist is contained in `lib/tw/conf/vip_words.txt`. Words must be separated by newline. There is a mapping between words and sounds played in a configuration object within `server/views/index.erb`.

VIPs are configured in `lib/tw/conf/vips.txt`. VIPs must be separated by newline.

The chatbot requires some environment varibles to run:
* `TW_OAUTH_STRING` (oauth token provided by Twitch when setting up a chatbot)
* `TW_TWITCH_USER` (username of the chatbot)
* `TW_TWITCH_CHANNEL` (channel the chatbot will listen in on/one channel per chatbot process)
* `TW_WSS_SERVER` (defaults to Twitch's irc-ws server)
* `TW_MEDIA_SERVER` (url to weboscket server contained in `server/`)

#### Sinatra configuration

Sinatra has the following environment variables:
* `development` (bind to localhost or 0.0.0.0 if present)
* `TW_TLS_ENABLED` (set up Sinatra ssl options if present)
* `TW_SERVER_CHAIN_PATH`
* `TW_SERVER_KEY_PATH`

### Running

Use `foreman start` from the project's root directory to start the chatbot and Sinatra at the same time. The chatbot will connect based on config and the webserver will start on `localhost:4567` or `0.0.0.0:4567` unless the development environment variable is set.
