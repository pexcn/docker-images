# php-proxy

## Usage

```sh
php-proxy -s <php-proxy-url> -p <password> -l <listen-address>
```

## Create Self-Signed Certificate

> Just for notes

```sh
# php-proxy.key
openssl ecparam -genkey -name prime256v1 -out php-proxy.key
# php-proxy.csr
openssl req -new -sha256 -subj "/CN=PHP-Proxy" -key php-proxy.key -out php-proxy.csr
# php-proxy.crt
openssl req -x509 -sha256 -days 18250 -in php-proxy.csr -key php-proxy.key -out php-proxy.crt
# verify
openssl req -in php-proxy.csr -text -noout
```
