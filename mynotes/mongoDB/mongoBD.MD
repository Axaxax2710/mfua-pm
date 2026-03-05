## MongoDB (NoSQL)

Выполните все этапы работы с проектом по примеру с [Nginx](/content/Docker/ImageLibrary/Nginx.md)

> Никогда в разработке не используйте русские имена файлов и каталогов!
> Никогда в разработке не используйте пробелы и спец.символы в именах файлов и каталогов!

1. Запуск MongoDB
```shell
docker run -d \
  --name my-mongo \
  -p 27017:27017 \
  mongo:latest
```
![](/mynotes/mongoDB/img/run.jpg)
2. Подключиться через shell
```shell
docker exec -it my-mongo mongosh
```
![](/mynotes/mongoDB/img/exec.jpg)

## После выполнения docker exec -it my-mongo mongosh вы попадёте в интерактивную оболочку MongoDB. Попробуйте следующие команды:
// Показать все базы данных
show dbs

// Переключиться на базу данных (или создать новую)
use mydb
![](/mynotes/mongoDB/img/show.jpg)

## Посмотреть логи	
    docker logs my-mongo
![](/mynotes/mongoDB/img/logs.jpg)
