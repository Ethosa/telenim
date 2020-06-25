# author: Ethosa
import
  asyncdispatch,
  httpclient,
  json,
  utils,
  consts
when defined(debug):
  import logging

export
  asyncdispatch,
  json


type
  TelegramApiRef* = ref object
    access_token: string
    client: AsyncHttpClient


proc TelegramApi*(access_token: string): TelegramApiRef =
  ## Creates a new telegram API object.
  ##
  ## Arguments:
  ## - `access_token` is a telegram bot access token
  result = TelegramApiRef()
  result.access_token = access_token
  result.client = newAsyncHttpClient()


proc call_method*(self: TelegramApiRef, method_name: string, args: JsonNode): Future[JsonNode] {.async.} =
  ## Calls any telegram API method.
  ##
  ## Arguments:
  ## - `method_name` is a name of called method.
  ## - `args` - method arguments.
  var url = API_URL & self.access_token & "/" & method_name
  result = parseJson await self.client.postContent(url, args.encode())

  when defined(debug):
    if result["ok"].getBool():
      debug("method " & method_name & " successfully called.")
    else:
      debug("error in method " & method_name & ": " & $result)


import macros


when defined(dotOperators):
  # enables methods calling via `.()`
  macro call*(o: TelegramApiRef, field: untyped, args: varargs[untyped]): untyped =
    result = newCall("call_method", o, newLit($field))
    var params = newNimNode(nnkTableConstr)
    for arg in args:
      params.add(newTree(nnkExprColonExpr, arg[0].toStrLit(), arg[1]))
    result.add(newCall("%*", params))

  template `.()`*(o: TelegramApiRef, field: untyped, args: varargs[untyped]): Future[JsonNode] =
    call(o, field, args)
else:
  macro `~`*(o: TelegramApiRef, callable: untyped): untyped =
    result = newCall("call_method", o, newLit($callable[0]))
    var params = newNimNode(nnkTableConstr)
    for arg in callable[1..^1]:
      params.add(newTree(nnkExprColonExpr, arg[0].toStrLit(), arg[1]))
    result.add(newCall("%*", params))
