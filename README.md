# antoinefromafar_bot
 Un bot inline Telegram pour lire les messages avec la voix "AntoineFromAfar" de Acapela 

utilisation: `./antoinefromafar_bot.rb [token de l'API de bots Telegram] [fichier de cookies]`

## Création et mise à jour des cookies
Un fichier de cookies valide dans le format "cookies.txt" contenant des informations de connexion au site acapela-group.com est nécessaire. S'il est invalide, une musique de fond sera présente sur les messages générés.
Pour le générer, et les regénerer avant qu'ils n'expirent, créez une tâche cron avec cette commande :
`bash -c 'curl -c /home/siphonay/acapela-cookie.txt http://www.acapela-group.com && curl -b [chemin vers les fichiers de cookies] -c [chemin vers les fichiers de cookies] http://www.acapela-group.com//wp-login.php -d "log=USERNAME&pwd=PASSWORD&submit=Log+in&remember-me=forever&redirect_to=http%3A%2F%2Fwww.acapela-group.com" && curl --cookie [chemin vers les fichiers de cookies] http://www.acapela-group.com'`
Remplacez USERNAME et PASSWORD par vos identifiants du site de Acapela. La création de comptes sur ce site est gratuite.