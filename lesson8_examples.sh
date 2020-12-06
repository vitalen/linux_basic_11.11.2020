# Урок 8
# Введение в Docker


# Разбор ДЗ 7

### 1. Подключить репозиторий с nginx любым удобным способом, установить nginx и потом удалить nginx, используя утилиту dpkg.

# Добавление репозитория через редактирование файла /etc/apt/source.list 

# Переходим в папку /etc/apt/sources.list.d/
cd /etc/apt/sources.list.d/

# Добавляем в конец строку нового репозитория для nginx
deb http://nginx.org/packages/ubuntu focal nginx

# Добавим ключ, который используется для проверки  
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -

# Выполняем обновление источников репозиториев
sudo apt update 

# Устанавливаем nginx уже из нужного репозитория
apt install nginx

# Добавление репозитория, используя команду apt-add-repository
sudo apt-add-repository ppa:nginx/stable 

# удалить пакет или групcdпу пакетов
sudo dpkg -r nginx

### 2. Установить пакет на свой выбор, используя snap.

# Установка пакета
snap install p7zip-desktop

### 3. Настроить iptables: разрешить подключения только на 22-й и 80-й порты.
# Действия по умолчанию
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Разрешаем обмен по локальной петле
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Разрешаем пакеты icmp (для обмена служебной информацией)
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# Разрешаем соединения с динамических портов
iptables -A OUTPUT -p TCP -m tcp --sport 32768:61000 -j ACCEPT
iptables -A OUTPUT -p UDP -m udp --sport 32768:61000 -j ACCEPT

# Разрешить только те пакеты, которые мы запросили
iptables -A INPUT -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p UDP -m state --state ESTABLISHED,RELATED -j ACCEPT

# Разрешаем ssh
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT 
iptables -A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT

# Разрешаем http
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --sport 80 -j ACCEPT

### 4. * Настроить проброс портов локально с порта 80 на порт 8080.
sudo sysctl -w net.ipv4.ip_forward=1

# Действия по умолчанию
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Разрешаем обмен по локальной петле
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Разрешаем пакеты icmp (для обмена служебной информацией)
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# Разрешаем соединения с динамических портов
iptables -A OUTPUT -p TCP -m tcp --sport 32768:61000 -j ACCEPT
iptables -A OUTPUT -p UDP -m udp --sport 32768:61000 -j ACCEPT

# Разрешить только те пакеты, которые мы запросили
iptables -A INPUT -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p UDP -m state --state ESTABLISHED,RELATED -j ACCEPT

# Разрешаем работу с портом 8080
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --sport 8080 -j ACCEPT

# Настроим перенаправление с порта 8080 на порт 80
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080



# Введение в Docker
# Установка Docker
# установим пакеты, необходимые для работы apt по протоколу HTTPS
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# Добавляем ключ репозитория
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Подключаем репозиторий
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Обновляем список пакетов
sudo apt update

# устанавливаем пакет
sudo apt install docker-ce -y

# Либо можно установить через репозитории Ubuntu
sudo apt install -y docker docker-compose

# убедиться, что демон стартовал
sudo systemctl status docker

# запустить тестовый контейнер
sudo docker run hello-world

# Добавим пользователя в группу sudo
sudo usermod -aG docker victor

# Заходим в новую сессию
su ubuntu


# Управление образами и контейнерами
# поиск образа в реестре
docker search nginx

# скачает диск из реестра
docker pull nginx

# Создадим файл приветствия 
sudo cat > /var/www/html/index.html
<h1>Hello, team!</h1>

# запустим контейнер nginx из уже скачанного образа
docker run -d --name nginx -p 80:80 -v /var/www/html:/usr/share/nginx/html nginx 

# Просмотреть список запущенных контейнеров
docker ps

# Остановим контейнер
docker stop nginx

# Получить список всех контейнеров
docker container ps -a

# создать Dockerfile
cat > Dockerfile
FROM ubuntu:latest
MAINTAINER User GB
RUN apt-get update
RUN apt-get install nginx -y
VOLUME "/var/www/html"
EXPOSE 80
CMD /usr/sbin/nginx -g "daemon off;"

# Запускаем сборку
docker build -t nginx_custom_image .
docker images
# запускаем контейнер из собранного нами образа
docker run -d --name nginx_custom_image -p 80:80 main_image_nginx

# Управление сетями в Docker

# Bridge интефейс docker0
ip a

# Просмотреть доступные сети можно командой
docker network ls

# контейнеры, которые работают в этой сети
docker network inspect bridge


# Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# выставить права на исполнение
sudo chmod +x /usr/local/bin/docker-compose

# Соберём контейнер c nginx, используя Docker Compose
nano docker-compose.yml

version: '3'
services:
  nginx:
    image: nginx:latest
    ports:
      - 80:80
    volumes:
      - /var/www/html
sudo 
# Запускаем наш проект
sudo docker-compose up -d --build


# Некоторые дополнительные команды для работы
# Зайти в оболочку контейнера
docker exec -ti nginx bash

# Перезагрузка контейнера
docker restart nginx

# Отправка другого сигнала в контейнер
docker kill -s HUP nginx

# Логи контейнера
docker logs nginx

# Информация о контейнере
docker inspect nginx

# Публичные порты
docker port nginx

# Выполняющиеся процессы
docker top nginx

# Использование ресурсов
docker stats nginx

# Список образов
docker images

# Просмотр истории образа
docker history nginx

# Удаление контейнера
docker stop nginx
docker rm nginx

# Удаление образа
docker rmi nginx







