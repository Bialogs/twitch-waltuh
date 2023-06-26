Tw is a combination Sinatra and Twitch Chat bot that analyzes chat messages in real time for an order of words. When the order of words is found, the chat bot sends an async websocket request to the Sinatra server, which will forward it to all connected clients, and those clients will play the mp3. Tw can also run in local mode, without a Sinatra server. The local mode will play the sound over default audio device using an async event. The webserver can be added as an OBS browser source after autoplay has been enabled to play the sounds through the stream.

### Internal Design

Tw is based on the same architecture as my `tsc` project. The main addition is the Sinatra server so that users do not have to spend time setting up WSL or Ruby for Windows. Secondarily, Tw uses the `EventMachine#defer` pattern to background I/O tasks such as playing the audio or sending additional websocket requests to the media server in server mode as well as offloading logic for calculating if events have been triggered.

The main `tw.rb` module sets up `Handlers`, `Conf`, and the websocket connection. It then enters into the main `EventMachine` loop where on new websocket messages a sound event handler is started via `EM#defer`. Some handlers and functions are executing via `EventMachine#add_periodic_timer`.

To add new triggers for sounds, create a new handler with callbacks expected by `EM#defer` and add an entry into the list `on :message`. In the implementation of a handler it is important to use a `Mutex` to synchronize access to buffers and shared state since the trigger logic can run in different EventMachine threads at once. There is a bit of a limit on how many handlers that can be created due to the internal `EventMachine` limit 20 threads assigned for deferred execution.

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

### Handlers

List of handlers, what they do, how to trigger them, and configuration.

#### Combo

Combo will play a sound when 5 of the same words are sent in a row by 5 unique chatters.

```
@comboers # length of combo and amount of unique chatters
```

#### RandomEmote

Pick a random emote from `emotes.txt`, and play a sound when it is used in chat.

#### Randomizer

Randomize the order of words in `random_words.txt`. When the correct order is typed by the chat consecutively, play a sound.

#### Six

Some chats have a random dice roll feature built in. When that rolls a 6, play a sound.

```
@bot # what bot will be performing the roll
@text # the text to look for
```

#### Sunnies

When 10 emotes from `sunnies_words.txt` are typed in a row, play a sound. `sunnies_words.txt` must be the only word in the message and the chatters must be unique.

```
@max # number of sunnies_words.txt that need to be sent to trigger a sound
```

#### Users

When any user in the `users.txt` list sends a chat message, play a sound.

#### Vips

When a user is added to `vips.txt` they can use the command `!sound` in combination with a word in `vip_words.txt` to play the sound. Each user in the list has a cooldown and each sound has a cooldown. The chatbot will let the user know if the sound or they are on cooldown.

#### VoteKick

When a set of words is sent in a certain amount of time by unique chatters, play a sound.

```
@vote_words # set of words that must be completed in the timeframe
@vote_seconds # amount of time before all words need to be sent in the chat
```
