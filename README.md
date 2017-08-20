# antoinefromafar_bot
an inline Telegram bot to use the "WillFromAfar" voice from acapela

utilisation: `./antoinefromafar_bot.rb [telegram API token] [cookies file]`

## Creating and updating cookies

A valid cookies file in the "cookies.txt" format containing login information to the acapela-group.com website is required. If it is invalid, a background music will be present on the generated messages.
To generate and regenerate them before they expire, create a cron job with this command:

`bash -c 'curl -c [chemin vers les fichiers de cookies] http://www.acapela-group.com && curl -b [chemin vers les fichiers de cookies] -c [chemin vers les fichiers de cookies] http://www.acapela-group.com//wp-login.php -d "log=USERNAME&pwd=PASSWORD&submit=Log+in&remember-me=forever&redirect_to=http%3A%2F%2Fwww.acapela-group.com" && curl --cookie [chemin vers les fichiers de cookies] http://www.acapela-group.com'`

Replace USERNAME and PASSWORD by your creditentials for the Acapela website. Creating an account on this site is free.
