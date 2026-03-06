## hello-world

```dockerfile
# Используем минимальный базовый образ Alpine Linux
FROM alpine:latest
# Команда, которая выполнится при запуске контейнера
CMD ["echo", "Привет, Docker! 🐳"]
```
Сборка
```shell
docker build -t hello-world .
```
Запуск
```shell
docker run --rm hello-world
```

![Скриншот из командной строки](/content/img/docker_hello_world.png)