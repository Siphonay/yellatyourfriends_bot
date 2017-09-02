# yellatyourfriends_bot
an inline Telegram bot to use the "WillFromAfar" voice from acapela

usage: `./yellatyourfriends_bot.rb [telegram API token] [cookies file]`

## Creating and updating cookies

A valid cookies file in the "cookies.txt" format containing login information to the acapela-group.com website is required. If it is invalid, a background music will be present on the generated messages.
To generate and regenerate them before they expire, create a cron job running the script provided in this repo with these environment variables:

* `COOKIES_PATH` (path to your cookies file)
* `ACAPELA_USER` (your acapela-group.com username)
* `ACAPELA_PASS` (your acapela-group.com password)
