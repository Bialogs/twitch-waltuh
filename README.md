Tw is a combination Sinatra and Twitch Chat bot that analyzes chat messages in real time for an order of words. When the order of words is found, the chat bot sends an async websocket request to the Sinatra server, which will forward it to all connected clients, and those clients will play the mp3. Tw can also run in local mode, without a Sinatra server. The local mode will play the sound over default audio device using an async event.
