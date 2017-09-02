#!/bin/bash

curl -c $COOKIES_PATH http://www.acapela-group.com
curl -b $COOKIES_PATH -c $COOKIES_PATH http://www.acapela-group.com//wp-login.php -d "log=$ACAPELA_USER&pwd=$ACAPELA_PASS&submit=Log+in&remember-me=forever&redirect_to=http%3A%2F%2Fwww.acapela-group.com"
curl --cookie $COOKIES_PATH http://www.acapela-group.com
