На сервере выполнить команду:
``` shell 
docker run amir20/dozzle generate admin --password password --email admin@mail.ru --name "admin" > ./data/users.yml 
```


password, admin и admin@mail.ru - поменять на нужные креды.

После перезапустить контейнер dozzle и заработает авторизация.

``` shell
docker-compose down
```

``` shell 
docker-compose up -d
```