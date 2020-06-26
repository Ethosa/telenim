# --- Test 2. Handle real-time events --- #
import telenim

var api = TelegramApi("8123080:asdbajsbhdiahsbd")

api@message(event):
  echo event.text

api.listen()
