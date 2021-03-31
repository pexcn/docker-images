%any %any : PSK "passwd"
user %any : EAP "passwd"

: XAUTH "passwd"
%any %any : EAP "passwd"

test : XAUTH "user password"
test : EAP "user password"
