# frozen_string_literal: true

require 'net/http'
require 'json'

channel_id = ARGV[0]

uri = URI('https://7tv.io/v3/gql')
headers = {
  'Host': '7tv.io',
  'Accept': '*/*',
  'Referer': 'https://7tv.app/',
  'content-type': 'application/json'
}
request_content = JSON.dump({"operationName":"AppState","variables":{},"query":"query AppState {\n  globalEmoteSet: namedEmoteSet(name: GLOBAL) {\n    id\n    name\n    emotes {\n      id\n      name\n      flags\n      __typename\n    }\n    capacity\n    __typename\n  }\n  roles: roles {\n    id\n    name\n    allowed\n    denied\n    position\n    color\n    invisible\n    __typename\n  }\n}"})
global_emotes = JSON.parse(Net::HTTP.post(uri, request_content, headers).body)

request_content = JSON.dump({"operationName":"GetEmoteSet","variables":{"id": channel_id},"query":"query GetEmoteSet($id: ObjectID!, $formats: [ImageFormat!]) {\n  emoteSet(id: $id) {\n    id\n    name\n    flags\n    capacity\n    origins {\n      id\n      weight\n      __typename\n    }\n    emotes {\n      id\n      name\n      actor {\n        id\n        display_name\n        avatar_url\n        __typename\n      }\n      origin_id\n      data {\n        id\n        name\n        flags\n        state\n        lifecycle\n        host {\n          url\n          files(formats: $formats) {\n            name\n            format\n            __typename\n          }\n          __typename\n        }\n        owner {\n          id\n          display_name\n          style {\n            color\n            __typename\n          }\n          roles\n          __typename\n        }\n        __typename\n      }\n      __typename\n    }\n    owner {\n      id\n      username\n      display_name\n      style {\n        color\n        __typename\n      }\n      avatar_url\n      roles\n      connections {\n        id\n        display_name\n        emote_capacity\n        platform\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}"})
channel_emotes = JSON.parse(Net::HTTP.post(uri, request_content, headers).body)

emote_names = []
emote_names.push(global_emotes["data"]["globalEmoteSet"]["emotes"].map { |emote| emote["name"] })
emote_names.push(channel_emotes["data"]["emoteSet"]["emotes"].map { |emote| emote["name"] })

emote_names.flatten!
emote_names.uniq!
emote_names.sort!

out = File.open('../lib/tw/conf/emotes.txt', 'w')
out.write(emote_names.join("\n"))
out.close
