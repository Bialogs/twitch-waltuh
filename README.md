Tw is a combination Sinatra and Twitch Chat bot that analyzes chat messages in real time for an order of words. When the order of words is found, the chat bot sends an async websocket request to the Sinatra server, which will forward it to all connected clients, and those clients will play the mp3. Tw can also run in local mode, without a Sinatra server. The local mode will play the sound over default audio device using an async event.

### Design

Tw is based on the same architecture as my `tsc` project. The main addition is the Sinatra server so that users do not have to spend time setting up WSL or Ruby for Windows. Secondarily, Tw uses the `EventMachine#defer` mechanism to background I/O tasks such as playing the audio in local mode, or sending additional websocket requests to the media server in server mode.

### Configuration

#### Chatbot configuration

Wordlist is contained in `lib/tw/conf/words.txt`. Words must be separated by newline.

When operating in local mode, the sound played can be configured by changing the mp3 in `lib/tw/media` and updating the name of the media file in `Media::LocalPlayer#initalize`

The chatbot requires some environment varibles to run:
* `TW_OAUTH_STRING` (oauth token provided by Twitch when setting up a chatbot)
* `TW_TWITCH_USER` (username of the chatbot)
* `TW_TWITCH_CHANNEL` (channel the chatbot will listen in on/one channel per chatbot process)
* `TW_WSS_SERVER` (defaults to Twitch's irc-ws server)
* `TW_MODE` (defaults to local but setting it to anything else, like server, will send playback to `TW_MEDIA_SERVER`)
* `TW_MEDIA_SERVER` (weboscket server contained in `server/`)

#### Sinatra configuration

The only configuration available for the Sinatra server is changing the media file played. To do this, update the `server/public` file and change the name of the file in the `/sound` route in `server/app.rb` to the same name.
