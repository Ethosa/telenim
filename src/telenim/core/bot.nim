# author: Ethosa
import
  asyncdispatch,
  httpclient,
  json,
  utils,
  os,
  macros,

  consts,
  types
when defined(debug):
  import logging

export
  asyncdispatch,
  json


type
  TelegramMessageHandler* = proc(event: Message): Future[void]
  TelegramUpdateHandler* = proc(event: Update): Future[void]
  TelegramJsonHandler* = proc(event: JsonNode): Future[void]

  TelegramApiRef* = ref object
    running*: bool
    access_token: string
    client: AsyncHttpClient


var
  last_event: int = 0
  tmessage_handler*: TelegramMessageHandler
  tupdate_handler*: TelegramUpdateHandler
  tjson_handler*: TelegramJsonHandler

if existsFile("botinfo.json"):
  var botinfo: JsonNode = parseFile("botinfo.json")
  last_event = botinfo["offset"].getInt()


proc TelegramApi*(access_token: string): TelegramApiRef =
  ## Creates a new telegram API object.
  ##
  ## Arguments:
  ## - `access_token` is a telegram bot access token
  result = TelegramApiRef()
  result.running = true
  result.access_token = access_token
  result.client = newAsyncHttpClient()


proc callMethod*(self: TelegramApiRef, method_name: string, args: JsonNode = %*{}): Future[JsonNode] {.async.} =
  ## Calls any telegram API method.
  ##
  ## Arguments:
  ## - `method_name` is a name of called method.
  ## - `args` - method arguments.
  var url = API_URL & self.access_token & "/" & method_name
  var response = await self.client.request(
    url, "POST", args.encode(), newHttpHeaders({"Content-type": "application/x-www-form-urlencoded"})
  )
  result = parseJson await response.body

  when defined(debug):
    if result["ok"].getBool():
      debug("method " & method_name & " successfully called.")
    else:
      debug("error in method " & method_name & ": " & $result)


iterator pollEvents*(self: TelegramApiRef): JsonNode =
  ## Real-time receiving events.
  while self.running:
    var
      url = API_URL & self.access_token & "/getUpdates"
      updates = (parseJson waitFor self.client.postContent(url & "?offset=" & $last_event))["result"]

    for event in updates.items():
      last_event = event["update_id"].getInt() + 1
      yield event

    if updates.len() > 0:
      var f = open("botinfo.json", fmWrite)
      f.write($(%*{
        "offset": last_event
      }))
      f.close()


when defined(dotOperators):
  # enables methods calling via `.()`
  macro call*(o: TelegramApiRef, field: untyped, args: varargs[untyped]): untyped =
    result = newCall("callMethod", o, newLit($field))
    var params = newNimNode(nnkTableConstr)
    for arg in args:
      params.add(newTree(nnkExprColonExpr, arg[0].toStrLit(), arg[1]))
    result.add(newCall("%*", params))

  template `.()`*(o: TelegramApiRef, field: untyped, args: varargs[untyped]): Future[JsonNode] =
    call(o, field, args)
else:
  macro `~`*(o: TelegramApiRef, callable: untyped): untyped =
    result = newCall("callMethod", o, newLit($callable[0]))
    var params = newNimNode(nnkTableConstr)
    for arg in callable[1..^1]:
      params.add(newTree(nnkExprColonExpr, arg[0].toStrLit(), arg[1]))
    result.add(newCall("%*", params))


macro `@`*(o: TelegramApiRef, field, stmtlist: untyped): untyped =
  var arg = field[1]
  case $field[0]
  of "message":
    result = quote do:
      tmessage_handler =
        proc(`arg`: Message) {.async.} =
          `stmtlist`
  of "update":
    result = quote do:
      tupdate_handler =
        proc(`arg`: Update) {.async.} =
          `stmtlist`
  of "jupdate":
    result = quote do:
      tjson_handler =
        proc(`arg`: JsonNode) {.async.} =
          `stmtlist`
  else:
    discard

template listen*(o: TelegramApiRef): untyped =
  proc listenHandler {.async.} =
    for event in o.pollEvents():
      if not tjson_handler.isNil():
        await tjson_handler(event)
      if not tupdate_handler.isNil():
        await tupdate_handler(newUpdate(event))
      if not tmessage_handler.isNil() and event.hasKey("message"):
        await tmessage_handler(newMessage(event["message"]))
  waitFor listenHandler()
