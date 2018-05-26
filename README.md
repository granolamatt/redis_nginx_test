# redis_nginx_test
Quick test of nginx websocket server and redis pub sub

First install openresty https://openresty.org/en/installation.html for the server
and python-redis for the client and redis-server and start the server

Then, cd into the repo directory and run ./start_server.sh

Connect the the websocket server at ws://localhost:9000/foo/blah/events
I used https://websocket.org/echo.html for testing

Finally run pub.py to pub an event to the redis server.

