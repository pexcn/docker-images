# mysql

## 使用

```bash
# mysql 5.x
docker run -d \
  --name mysql-5 \
  --restart unless-stopped \
  --network host \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=password \
  -e MYSQL_DATABASE=db_name \
  -e MYSQL_ROOT_PASSWORD=root_password \
  -v /root/docker/mysql-5-data:/var/lib/mysql \
  mysql:5 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

# mysql 8.x
# TODO...
```

```bash
# import database from sql
docker exec -i mysql-5 \
  mysql -uusername -ppassword database_name < database.sql --default-character-set=utf8mb4
```
