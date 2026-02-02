# Docker и Docker Compose - Полное руководство

## 📋 Содержание
1. [Dockerfile - Полное руководство](#dockerfile-полное-руководство)
2. [Docker Compose - Полное руководство](#docker-compose-полное-руководство)
3. [Примеры использования](#примеры-использования)
4. [Лучшие практики](#лучшие-практики)
5. [Устранение неполадок](#устранение-неполадок)

---

## 🐳 Dockerfile - Полное руководство

### Что такое Dockerfile?
Dockerfile - это текстовый файл с инструкциями для сборки Docker-образа. Он описывает все шаги, необходимые для создания контейнеризованного приложения.

### Структура Dockerfile

```dockerfile
# Базовый образ
FROM ubuntu:22.04

# Метаданные
LABEL maintainer="dev@example.com"
LABEL version="1.0"

# Переменные окружения
ENV NODE_ENV=production
ENV PORT=3000

# Рабочая директория
WORKDIR /app

# Копирование файлов
COPY package*.json ./
COPY . .

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && npm ci --only=production \
    && apt-get clean

# Открытие портов
EXPOSE 3000

# Точка входа
CMD ["node", "server.js"]
```

### Директивы Dockerfile

#### 1. **FROM**
```dockerfile
FROM <image>[:<tag>] [AS <name>]
```
- Определяет базовый образ
- Должна быть первой директивой (кроме ARG)

**Примеры:**
```dockerfile
FROM alpine:latest
FROM node:18-alpine AS builder
FROM nginx:1.23
```

#### 2. **LABEL**
```dockerfile
LABEL <key>=<value> <key>=<value>
```
- Добавляет метаданные к образу
- Рекомендуется для документирования

**Пример:**
```dockerfile
LABEL maintainer="john@doe.com"
LABEL version="2.1.0"
LABEL description="Web application"
```

#### 3. **ENV**
```dockerfile
ENV <key>=<value>
ENV <key> <value>
```
- Устанавливает переменные окружения
- Доступны во время сборки и выполнения

**Пример:**
```dockerfile
ENV APP_HOME=/app
ENV NODE_ENV=production
ENV PORT=8080
```

#### 4. **ARG**
```dockerfile
ARG <name>[=<default value>]
```
- Определяет переменные, передаваемые при сборке
- Не сохраняются в конечном образе

**Пример:**
```dockerfile
ARG VERSION=latest
FROM ubuntu:$VERSION
```

#### 5. **WORKDIR**
```dockerfile
WORKDIR /path/to/workdir
```
- Устанавливает рабочую директорию
- Создает директорию, если не существует

**Пример:**
```dockerfile
WORKDIR /app
WORKDIR src
# Текущий путь: /app/src
```

#### 6. **COPY**
```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
```
- Копирует файлы и директории из хоста в образ

**Пример:**
```dockerfile
COPY package.json ./
COPY src/ ./src/
COPY --chown=node:node . .
```

#### 7. **ADD**
```dockerfile
ADD [--chown=<user>:<group>] <src>... <dest>
```
- Аналогично COPY, но с дополнительными возможностями:
  - Распаковка архивов (.tar, .gz)
  - Загрузка из URL

**Пример:**
```dockerfile
ADD https://example.com/file.tar.gz /tmp/
ADD app.tar.gz /app/
```

#### 8. **RUN**
```dockerfile
RUN <command>
RUN ["executable", "param1", "param2"]
```
- Выполняет команды в процессе сборки
- Каждый RUN создает новый слой

**Пример:**
```dockerfile
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
```

#### 9. **CMD**
```dockerfile
CMD ["executable","param1","param2"]
CMD command param1 param2
```
- Определяет команду по умолчанию при запуске контейнера
- Только одна CMD на Dockerfile
- Может быть переопределена при запуске

**Пример:**
```dockerfile
CMD ["node", "app.js"]
CMD npm start
```

#### 10. **ENTRYPOINT**
```dockerfile
ENTRYPOINT ["executable", "param1", "param2"]
ENTRYPOINT command param1 param2
```
- Определяет основную команду контейнера
- Аргументы CMD передаются как параметры ENTRYPOINT

**Пример:**
```dockerfile
ENTRYPOINT ["python3"]
CMD ["app.py"]
```

#### 11. **EXPOSE**
```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```
- Документирует, какие порты прослушивает контейнер
- Не открывает порты автоматически

**Пример:**
```dockerfile
EXPOSE 80/tcp
EXPOSE 443
EXPOSE 3000 8080
```

#### 12. **VOLUME**
```dockerfile
VOLUME ["/data"]
VOLUME /var/log
```
- Создает точку монтирования для внешнего хранилища

**Пример:**
```dockerfile
VOLUME /var/lib/mysql
VOLUME ["/app/data", "/app/logs"]
```

#### 13. **USER**
```dockerfile
USER <user>[:<group>]
USER <UID>[:<GID>]
```
- Устанавливает пользователя для RUN, CMD, ENTRYPOINT

**Пример:**
```dockerfile
USER node
USER 1000:1000
```

#### 14. **HEALTHCHECK**
```dockerfile
HEALTHCHECK [OPTIONS] CMD command
HEALTHCHECK NONE
```
- Определяет как проверять здоровье контейнера

**Пример:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1
```

### Многоступенчатая сборка

```dockerfile
# Этап 1: Сборка
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Этап 2: Продакшн
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Лучшие практики для Dockerfile

1. **Используйте .dockerignore**
```dockerignore
node_modules
npm-debug.log
.git
*.md
.env
```

2. **Минимизируйте количество слоев**
```dockerfile
# Плохо
RUN apt-get update
RUN apt-get install -y python
RUN pip install -r requirements.txt

# Хорошо
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && pip3 install -r requirements.txt \
    && rm -rf /var/lib/apt/lists/*
```

3. **Используйте конкретные теги**
```dockerfile
# Плохо
FROM ubuntu

# Хорошо
FROM ubuntu:22.04
```

4. **Сортировка многострочных команд**
```dockerfile
RUN apt-get update && apt-get install -y \
    package-a \
    package-b \
    package-c \
    && rm -rf /var/lib/apt/lists/*
```

5. **Безопасность**
```dockerfile
# Создаем непривилегированного пользователя
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
```

### Сборка образа

```bash
# Базовая сборка
docker build -t myapp:latest .

# Сборка с контекстом
docker build -t myapp:v1.0 -f Dockerfile.prod .

# Сборка с аргументами
docker build --build-arg VERSION=2.0 -t myapp:2.0 .

# Сборка с кэшированием
docker build --no-cache -t myapp:latest .
```

---

## 🐳 Docker Compose - Полное руководство

### Что такое Docker Compose?
Docker Compose - это инструмент для определения и запуска многоконтейнерных приложений Docker. Использует YAML-файл для конфигурации.

### Структура docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
      - redis
    volumes:
      - ./app:/app
    networks:
      - app-network

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:alpine
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

### Основные секции docker-compose.yml

#### 1. **version**
```yaml
version: '3.8'
```
- Определяет версию формата файла
- Рекомендуется использовать 3.x

#### 2. **services**
```yaml
services:
  service-name:
    # конфигурация сервиса
```
- Основная секция для определения сервисов
- Каждый сервис - отдельный контейнер

#### 3. **build**
```yaml
build: .
build:
  context: .
  dockerfile: Dockerfile.prod
  args:
    VERSION: 2.0
```
- Указывает как собрать образ для сервиса

#### 4. **image**
```yaml
image: nginx:alpine
image: myapp:v1.0
```
- Использовать готовый образ вместо сборки

#### 5. **ports**
```yaml
ports:
  - "8080:80"
  - "3000:3000"
  - "127.0.0.1:5432:5432"
```
- Проброс портов: хост:контейнер

#### 6. **environment**
```yaml
environment:
  - DATABASE_URL=postgres://user:pass@db:5432/db
  - REDIS_HOST=redis
```
```yaml
environment:
  NODE_ENV: production
  PORT: 3000
```
- Переменные окружения для контейнера

#### 7. **env_file**
```yaml
env_file:
  - .env
  - .env.production
```
- Загрузка переменных из файлов .env

#### 8. **volumes**
```yaml
volumes:
  - /host/path:/container/path
  - named_volume:/container/path
  - ./relative/path:/container/path
```
- Монтирование томов и директорий

#### 9. **networks**
```yaml
networks:
  - frontend
  - backend
```
- Подключение сервиса к сетям

#### 10. **depends_on**
```yaml
depends_on:
  - db
  - redis
```
- Определяет порядок запуска сервисов

#### 11. **restart**
```yaml
restart: always
restart: unless-stopped
restart: on-failure
```
- Политика перезапуска контейнера

#### 12. **healthcheck**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```
- Проверка здоровья сервиса

### Расширенная конфигурация

#### Конфигурация развертывания (deploy)
```yaml
deploy:
  replicas: 3
  update_config:
    parallelism: 2
    delay: 10s
  restart_policy:
    condition: on-failure
    delay: 5s
  resources:
    limits:
      cpus: '0.50'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

#### Использование шаблонов
```yaml
services:
  app:
    image: app:${TAG:-latest}
    environment:
      - NODE_ENV=${NODE_ENV:-development}
```

#### Расширенные сетевые настройки
```yaml
networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  backend:
    external: true
    name: production-network
```

### Команды Docker Compose

#### Управление приложением
```bash
# Запуск всех сервисов
docker-compose up

# Запуск в фоновом режиме
docker-compose up -d

# Запуск с пересборкой
docker-compose up --build

# Остановка сервисов
docker-compose down

# Остановка с удалением томов
docker-compose down -v
```

#### Просмотр информации
```bash
# Список контейнеров
docker-compose ps

# Логи сервиса
docker-compose logs web
docker-compose logs -f web  # слежение за логами

# Статус сервисов
docker-compose top
```

#### Управление отдельными сервисами
```bash
# Запуск конкретного сервиса
docker-compose start web

# Остановка конкретного сервиса
docker-compose stop web

# Перезапуск сервиса
docker-compose restart web

# Выполнение команды в контейнере
docker-compose exec web bash
docker-compose exec db psql -U postgres
```

#### Сборка и образы
```bash
# Сборка образов
docker-compose build
docker-compose build --no-cache

# Просмотр образов
docker-compose images

# Удаление образов
docker-compose down --rmi all
```

#### Работа с томами
```bash
# Список томов
docker-compose volume ls

# Удаление неиспользуемых томов
docker-compose down -v
```

### Примеры конфигураций

#### Простое веб-приложение
```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: development
    volumes:
      - .:/app
      - /app/node_modules
```

#### Полноценный стек приложения
```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - REACT_APP_API_URL=http://backend:4000

  backend:
    build: ./backend
    ports:
      - "4000:4000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    volumes:
      - ./backend:/app

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: app
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - frontend
      - backend

volumes:
  postgres_data:

networks:
  default:
    name: app-network
```

#### Микросервисная архитектура
```yaml
version: '3.8'

services:
  api-gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./gateway/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - product-service
      - order-service

  user-service:
    build: ./services/user
    environment:
      SERVICE_NAME: user
      DATABASE_URL: postgres://user:pass@user-db:5432/users

  product-service:
    build: ./services/product
    environment:
      SERVICE_NAME: product
      DATABASE_URL: postgres://user:pass@product-db:5432/products

  order-service:
    build: ./services/order
    environment:
      SERVICE_NAME: order
      DATABASE_URL: postgres://user:pass@order-db:5432/orders

  user-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: users

  product-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: products

  order-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: orders

  redis:
    image: redis:alpine

  rabbitmq:
    image: rabbitmq:management-alpine
    ports:
      - "15672:15672"  # Management UI
```

---

## 📚 Примеры использования

### Пример 1: Node.js приложение с MongoDB

**Dockerfile:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - MONGODB_URI=mongodb://mongodb:27017/mydb
      - NODE_ENV=production
    depends_on:
      - mongodb
    volumes:
      - ./logs:/app/logs

  mongodb:
    image: mongo:6
    volumes:
      - mongo_data:/data/db
    ports:
      - "27017:27017"

volumes:
  mongo_data:
```

### Пример 2: Python Django с PostgreSQL

**Dockerfile:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/django
      - DEBUG=False
    depends_on:
      - db
    volumes:
      - .:/app
      - static_volume:/app/static
      - media_volume:/app/media

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: django
    volumes:
      - postgres_data:/var/lib/postgresql/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - static_volume:/static
      - media_volume:/media
    depends_on:
      - web

volumes:
  postgres_data:
  static_volume:
  media_volume:
```

---

## 🏆 Лучшие практики

### Для Dockerfile:
1. **Используйте многоступенчатую сборку** для минимизации размера образа
2. **Сортируйте зависимости** для эффективного кэширования
3. **Удаляйте кэш пакетов** после установки
4. **Используйте конкретные версии** тегов образов
5. **Создавайте непривилегированных пользователей** для безопасности
6. **Пишите .dockerignore файл** для исключения ненужных файлов

### Для Docker Compose:
1. **Используйте именованные тома** для персистентных данных
2. **Настраивайте healthcheck** для всех сервисов
3. **Используйте переменные окружения** для конфигурации
4. **Определите restart policy** для каждого сервиса
5. **Используйте depends_on** для правильного порядка запуска
6. **Разделяйте конфигурации** на development/production

### Безопасность:
1. **Не храните секреты** в Dockerfile или docker-compose.yml
2. **Используйте Docker secrets** для конфиденциальных данных
3. **Регулярно обновляйте** базовые образы
4. **Сканируйте образы** на уязвимости
5. **Используйте минимальные базовые образы** (Alpine, Distroless)

### Производительность:
1. **Кэшируйте зависимости** с помощью многоступенчатой сборки
2. **Минимизируйте количество слоев** в Dockerfile
3. **Используйте .dockerignore** для уменьшения контекста сборки
4. **Оптимизируйте порядок команд** в Dockerfile
5. **Используйте сборку в CI/CD** для кэширования слоев

---

## 🔧 Устранение неполадок

### Общие проблемы Dockerfile

#### Проблема 1: Большой размер образа
**Решение:**
```dockerfile
# Используйте многоступенчатую сборку
FROM node:18 AS builder
WORKDIR /app
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

#### Проблема 2: Медленная сборка
**Решение:**
- Сортируйте команды COPY от наименее к наиболее изменяемым
- Используйте .dockerignore
- Кэшируйте зависимости в отдельном слое

#### Проблема 3: Проблемы с правами
**Решение:**
```dockerfile
# Создайте пользователя
RUN adduser -D appuser
USER appuser
```

### Общие проблемы Docker Compose

#### Проблема 1: Сервисы не видят друг друга
**Решение:**
```yaml
# Используйте depends_on и правильные имена хостов
services:
  app:
    depends_on:
      - db
    environment:
      DB_HOST: db  # имя сервиса как хост
```

#### Проблема 2: Тома не сохраняют данные
**Решение:**
```yaml
# Используйте именованные тома
volumes:
  db_data:
    driver: local

services:
  db:
    volumes:
      - db_data:/var/lib/mysql
```

#### Проблема 3: Конфликты портов
**Решение:**
```bash
# Проверьте занятые порты
docker-compose ps
netstat -tulpn | grep :80

# Измените маппинг портов в docker-compose.yml
ports:
  - "8080:80"  # вместо "80:80"
```

### Полезные команды для отладки

```bash
# Проверка синтаксиса Dockerfile
docker build --no-cache -t test .

# Проверка синтаксиса docker-compose.yml
docker-compose config

# Подробный вывод сборки
docker-compose build --no-cache --progress=plain

# Просмотр логов всех сервисов
docker-compose logs --tail=50 -f

# Проверка сети
docker-compose exec app ping db

# Проверка томов
docker-compose exec db ls -la /var/lib/mysql

# Очистка системы
docker system prune -a --volumes
```

### Мониторинг и логи

```bash
# Реальный мониторинг ресурсов
docker stats

# Детальная информация о контейнере
docker inspect <container_id>

# Логи контейнера
docker logs <container_id>

# Выполнение команд в контейнере
docker exec -it <container_id> bash
```

---

## 📚 Полезные ресурсы

### Официальная документация:
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Best Practices for Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### Инструменты:
- [Docker Bench Security](https://github.com/docker/docker-bench-security)
- [Hadolint](https://github.com/hadolint/hadolint) - линтер для Dockerfile
- [Dive](https://github.com/wagoodman/dive) - анализ Docker-образов

### Образовательные ресурсы:
- [Docker Curriculum](https://docker-curriculum.com/)
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Samples](https://github.com/docker/awesome-compose)

---

**Примечание:** Этот README является общим руководством. Для конкретных проектов могут потребоваться дополнительные настройки и конфигурации в зависимости от требований приложения и инфраструктуры.