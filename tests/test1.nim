# --- Test 1. Auth. --- #
import telenim

var
  api = TelegramApi("8123080:asdbajsbhdiahsbd")

proc main {.async.} =
  echo await api~getMe(a=1, b=2, c="hello")

waitFor main()
