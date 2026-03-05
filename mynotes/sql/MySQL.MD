## MySQL база данных

Выполните все этапы работы с проектом по примеру с [Nginx](/content/Docker/ImageLibrary/Nginx.md)

> Никогда в разработке не используйте русские имена файлов и каталогов!
> Никогда в разработке не используйте пробелы и спец.символы в именах файлов и каталогов!

1. Запуск MySQL
```shell
docker run -d \
  --name my-mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=password \
  mysql:8
```
2. Подключиться
```shell
docker exec -it my-mysql mysql -u root -p
```
> Пароль: rootpassword

Повыполняйте какие-нибудь команды SQL для проверки и пришлите скрины.
После успешного подключения к MySQL выполните следующие SQL-команды для проверки работоспособности и создания тестовых данных.
Все команды выполняются в интерактивной оболочке MySQL (после mysql>).

📌 Примеры SQL-команд
sql
-- 1. Просмотр списка баз данных
SHOW DATABASES;
![SHOW](/mynotes/sql/images/SHOW.jpg)


-- 2. Выбор базы данных, созданной при запуске (mydb)
USE mydb;
![USE](/mynotes/sql/images/USE.jpg)

-- 3. Создание таблицы пользователей
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
![CREATE](/mynotes/sql/images/CREATE.jpg)

-- 4. Вставка тестовых данных
INSERT INTO users (name, email) VALUES
('Иван Петров', 'ivan@example.com'),
('Мария Смирнова', 'maria@example.com'),
('Петр Сидоров', 'petr@example.com');
![INSERT](/mynotes/sql/images/INSERT.jpg)

-- 5. Выборка всех записей
SELECT * FROM users;
![SELECT](/mynotes/sql/images/SELECT.jpg)
