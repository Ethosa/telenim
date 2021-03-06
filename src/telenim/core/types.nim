# author: Ethosa
import json

type
  ChatType* {.pure.} = enum
    CHATTYPE_PRIVATE,
    CHATTYPE_GROUP,
    CHATTYPE_SUPERGROUP,
    CHATTYPE_CHANNEL


type
  User* = ref object
    id*: int  ## Unique identifier for user or bot
    first_name*: string  ## Bot or user name
    last_name*: string  ## Optionally. Last name of bot or user
    username*: string  ## Optionally. Username of user or bot

  Chat* = ref object
    id*: int  ## Unique chat identifier. The absolute value does not exceed 1e13
    `type`*: ChatType  ## Chat type: “private”, “group”, “supergroup” or “channel”
    title*: string  ## Optionally. Name, for channels or groups
    username*: string  ## Optionally. Username, for chats and some channels
    first_name*: string  ## Optionally. Chat name
    last_name*: string  ## Optionally. Chat last name
    all_members_are_administrators*: bool  ## Optional. True if all chat members are administrators

  Message* = ref object
    message_id*: int  ## Unique message identifier
    `from`*: User  ## Optionally. Sender. May be empty in channels.
    date*: int  ## Message Submission Date (Unix time)
    chat*: Chat  ## The dialogue in which the message was sent
    forward_from*: User  ## Optionally. For Forwarded Messages: Sender of the original message
    forward_date*: int  ## Optionally. For Forwarded Messages: Date the original message was sent.
    reply_to_message*: Message  ## Optionally. For answers: the original message. Note that the Message object in this field will not contain further reply_to_message fields even if it itself is a reply.
    text*: string  ## Optionally. For text messages: message text, 0-4096 characters
    entities*: seq[MessageEntity]  ## Optionally. For text messages: special entities in the text of the message.
    audio*: Audio  ## Optionally. Audio File Information
    document*: Document  ## Optionally. File info
    photo_sizes*: seq[PhotoSize]  ## Optionally. Available photo sizes
    sticker*: Sticker  ## Optionally. Sticker Information
    video*: Video  ## Optionally. Video Information
    voice*: Voice  ## Optionally. Voice Message Information
    caption*: string  ## Optionally. File caption, photo or video, 0-200 characters
    contact*: Contact  ## Optionally. Contact information sent
    location*: Location  ## Optionally. Location information
    venue*: Venue  ## Optionally. Information about the place on the map
    new_chat_member*: User  ## Optionally. Information about the user added to the group
    left_chat_member*: User  ## Optionally. Information about the user removed from the group
    new_chat_title*: string  ## Optionally. Group name has been changed to this field.
    new_chat_photo: seq[PhotoSize]  ## Optionally. Group photo has been changed to this field.
    delete_chat_photo*: bool  ## Optionally. Service message: group photo has been deleted
    group_chat_created*: bool  ## Optionally. Service message: group created
    supergroup_chat_created*: bool  ## Optionally. Service message: supergroup created
    channel_chat_created*: bool  ## Optionally. Service message: channel created
    migrate_to_chat_id*: int  ## Optionally. The group was transformed into a supergroup with the specified identifier. Does not exceed 1e13
    migrate_from_chat_id*: int  ## Optionally. The supergroup was created from the group with the specified identifier. Does not exceed 1e13
    pinned_message*: Message  ## Optionally. The specified message has been attached. Note that the Message object in this field will not contain further reply_to_message fields even if it is itself a reply.

  MessageEntity* = ref object
    `type`*: string  ## Type of the entity. One of mention (@username), hashtag, bot_command, url, email, bold (bold text), italic (italic text), code (monowidth string), pre (monowidth block), text_link (for clickable text URLs)
    offset*: int  ## Offset in UTF-16 code units to the start of the entity
    length*: int  ## Length of the entity in UTF-16 code units
    url*: string  ## Optionally. For “text_link” only, url that will be opened after user taps on the text

  PhotoSize* = ref object
    file_id*: string  ## Unique file id.
    width*: int  ## photo width
    height*: int  ## photo height
    file_size*: int  ## Optionally. File size
  
  Audio* = ref object
    file_id*: string  ## Unique file id
    duration*: int  ## Duration of the audio in seconds as defined by sender
    performer*: string  ## Optionally. Performer of the audio as defined by sender or by audio tags
    title*: string  ## Optionally. Title of the audio as defined by sender or by audio tags
    mime_type*: string  ## Optionally. MIME file specified by the sender
    file_size*: int  ## Optionally. File size

  Document* = ref object
    file_id*: string  ## Unique file identifier
    thumb*: PhotoSize  ## Optionally. Document thumbnail as defined by sender
    file_name*: string  ## Optionally. Original filename as defined by sender
    mime_type*: string  ## Optionally. MIME file specified by the sender
    file_size*: int  ## Optionally. File size

  Sticker* = ref object
    file_id*: string  ## Unique file identifier
    width*: int  ## sticker width
    height*: int  ## sticker height
    thumb*: PhotoSize  ## Optionally. sticker preview in format .jpg/.webp
    file_size*: int  ## Optionally. File size

  Video* = ref object
    file_id*: string  ## Unique file identifier
    width*: int  ## Sender video width
    height*: int  ## Sender video height
    duration*: int  ## Sender Video Duration
    thumb*: PhotoSize  ## Optionally. video preview
    mime_type*: string  ## Optionally. MIME file specified by the sender
    file_size*: int  ## Optionally. File size

  Voice* = ref object
    file_id*: string  ## Unique file identifier
    duration*: int  ## Audio file duration specified by sender
    mime_type*: string  ## Optionally. MIME file specified by the sender
    file_size*: int  ##  Optionally. File size

  Contact* = ref object
    phone_number*: string  ## Phone number
    first_name*: string  ## user name
    last_name*: string  ## Optionally. User last name
    user_id*: int  ## Optionally. Telegram user ID

  Location* = ref object
    longitude*: float  ## Sender Longitude
    latitude*: float  ## Latitude specified by sender

  Venue* = ref object
    location*: Location  ## Object coordinates
    title*: string  ## name of the property
    address*: string  ## Address of the object
    foursquare_id*: string  ## Optionally. Foursquare Object Id

  Update* = ref object
    update_id*: int
    message*: Message  ## Optionally. New incoming message of any kind - text, photo, sticker, etc.


template loadval(key: string, v: untyped, fn: untyped) =
  if obj.hasKey(`key`):
    result.`v` = obj[`key`].`fn`()


proc newUser*(obj: JsonNode): User =
  ## Creates a new User object from `obj`.
  result = User(id: obj["id"].getInt(), first_name: obj["first_name"].getStr())
  loadval("last_name", last_name, getStr)
  loadval("username", username, getStr)


proc newChat*(obj: JsonNode): Chat =
  ## Creates a new Chat object from `obj`.
  result = Chat(id: obj["id"].getInt())
  case obj["type"].getStr()
  of "private":
    result.`type` = CHATTYPE_PRIVATE
  of "group":
    result.`type` = CHATTYPE_GROUP
  of "supergroup":
    result.`type` = CHATTYPE_SUPERGROUP
  of "channel":
    result.`type` = CHATTYPE_CHANNEL
  else:
    discard
  loadval("title", title, getStr)
  loadval("first_name", first_name, getStr)
  loadval("last_name", last_name, getStr)
  loadval("username", username, getStr)
  loadval("all_members_are_administrators", all_members_are_administrators, getBool)


proc newPhotoSize*(obj: JsonNode): PhotoSize =
  ## Creates a new PhotoSize from `obj`.
  result = PhotoSize(file_id: obj["file_id"].getStr(),
    width: obj["width"].getInt(), height: obj["height"].getInt())
  loadval("file_size", file_size, getInt)


proc newMessageEntities*(obj: JsonNode): MessageEntity =
  ## Creates a new MessageEntity object from `obj`.
  result = MessageEntity(
    `type`: obj["type"].getStr(), offset: obj["offset"].getInt(),
    length: obj["length"].getInt())
  loadval("url", url, getStr)


proc newAudio*(obj: JsonNode): Audio =
  ## Creates a new Audio object from `obj`.
  result = Audio(file_id: obj["file_id"].getStr(), duration: obj["duration"].getInt())
  loadval("file_size", file_size, getInt)
  loadval("mime_type", mime_type, getStr)
  loadval("performer", performer, getStr)
  loadval("title", title, getStr)


proc newDocument*(obj: JsonNode): Document =
  ## Creates a new Document object from `obj`.
  result = Document(file_id: obj["file_id"].getStr())
  if obj.hasKey("thumb"):
    result.thumb = newPhotoSize(obj["thumb"])
  loadval("file_name", file_name, getStr)
  loadval("mime_type", mime_type, getStr)
  loadval("file_size", file_size, getInt)


proc newSticker*(obj: JsonNode): Sticker =
  ## Creates a new Sticker object from `obj`.
  result = Sticker(file_id: obj["file_id"].getStr(),
    width: obj["width"].getInt(), height: obj["height"].getInt())
  if obj.hasKey("thumb"):
    result.thumb = newPhotoSize(obj["thumb"])
  loadval("file_size", file_size, getInt)


proc newVideo*(obj: JsonNode): Video =
  ## Creates a new Voice object from `obj`.
  result = Video(
    file_id: obj["file_id"].getStr(), duration: obj["duration"].getInt(),
    width: obj["width"].getInt(), height: obj["height"].getInt()
  )
  loadval("mime_type", mime_type, getStr)
  loadval("file_size", file_size, getInt)
  if obj.hasKey("thumb"):
    result.thumb = newPhotoSize(obj["thumb"])


proc newVoice*(obj: JsonNode): Voice =
  ## Creates a new Voice object from `obj`.
  result = Voice(file_id: obj["file_id"].getStr(), duration: obj["duration"].getInt())
  loadval("mime_type", mime_type, getStr)
  loadval("file_size", file_size, getInt)


proc newContact*(obj: JsonNode): Contact =
  ## Creates a new Contact object from `obj`.
  result = Contact(phone_number: obj["phone_number"].getStr(), first_name: obj["first_name"].getStr())
  loadval("first_name", first_name, getStr)
  loadval("user_id", user_id, getInt)


proc newLocation*(obj: JsonNode): Location =
  ## Creates a new Location object from `obj`.
  result = Location(longitude: obj["longitude"].getFloat(), latitude: obj["latitude"].getFloat())


proc newVenue*(obj: JsonNode): Venue =
  ## Creates a new Venue object from `obj`.
  result = Venue(location: newLocation(obj["location"]), title: obj["title"].getStr(), address: obj["address"].getStr())
  loadval("foursquare_id", foursquare_id, getStr)


proc newMessage*(obj: JsonNode): Message =
  ## Creates a new Message object from `obj`.
  result = Message(message_id: obj["message_id"].getInt(), date: obj["date"].getInt())

  loadval("text", text, getStr)
  loadval("forward_date", forward_date, getInt)
  loadval("migrate_to_chat_id", migrate_to_chat_id, getInt)
  loadval("migrate_from_chat_id", migrate_from_chat_id, getInt)
  loadval("caption", caption, getStr)
  loadval("new_chat_title", new_chat_title, getStr)
  loadval("delete_chat_photo", delete_chat_photo, getBool)
  loadval("group_chat_created", group_chat_created, getBool)
  loadval("supergroup_chat_created", supergroup_chat_created, getBool)
  loadval("channel_chat_created", channel_chat_created, getBool)

  if obj.hasKey("from"):
    result.`from` = newUser(obj["from"])
  if obj.hasKey("forward_from"):
    result.forward_from = newUser(obj["forward_from"])
  if obj.hasKey("new_chat_member"):
    result.new_chat_member = newUser(obj["new_chat_member"])
  if obj.hasKey("left_chat_member"):
    result.left_chat_member = newUser(obj["left_chat_member"])

  if obj.hasKey("chat"):
    result.chat = newChat(obj["chat"])
  if obj.hasKey("location"):
    result.location = newLocation(obj["location"])
  if obj.hasKey("venue"):
    result.venue = newVenue(obj["venue"])
  if obj.hasKey("video"):
    result.video = newVideo(obj["video"])
  if obj.hasKey("voice"):
    result.voice = newVoice(obj["voice"])
  if obj.hasKey("sticker"):
    result.sticker = newSticker(obj["sticker"])
  if obj.hasKey("document"):
    result.document = newDocument(obj["document"])
  if obj.hasKey("audio"):
    result.audio = newAudio(obj["audio"])
  if obj.hasKey("pinned_message"):
    result.pinned_message = newMessage(obj["pinned_message"])

  if obj.hasKey("photo_sizes"):
    result.photo_sizes = @[]
    for i in obj["photo_sizes"].items():
      result.photo_sizes.add(newPhotoSize(i))

  if obj.hasKey("new_chat_photo"):
    result.new_chat_photo = @[]
    for i in obj["new_chat_photo"].items():
      result.new_chat_photo.add(newPhotoSize(i))

  if obj.hasKey("entities"):
    result.entities = @[]
    for i in obj["entities"].items():
      result.entities.add(newMessageEntities(i))


proc newUpdate*(obj: JsonNode): Update =
  ## Creates a new Update object from `obj`.
  result = Update(update_id: obj["update_id"].getInt())
  if obj.hasKey("message"):
    result.message = newMessage(obj["message"])
