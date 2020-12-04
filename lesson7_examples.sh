# Урок 7
# Управление пакетами и репозиториями. Основы сетевой безопасности

# Разбор ДЗ
### 1. Написать скрипт, который удаляет из текстового файла пустые строки и заменяет маленькие символы на большие. Воспользуйтесь tr или SED.

# СОздаём файл скрипта
cat > task1.sh
#!/bin/bash
tr -s '\n' < $1 | tr [:lower:] [:upper:] > $2

# Делаем его исполняемым
chmod +x task1.sh

# Вариант запуска
./task1.sh input.txt output.txt

### 2. Создать однострочный скрипт, который создаст директории для нескольких годов (2010–2017), в них — поддиректории для месяцев (от 01 до 12), и в каждый из них запишет несколько файлов с произвольными записями. Например, 001.txt, содержащий текст «Файл 001», 002.txt с текстом «Файл 002» и т. д.

for year in {2010..2017} 
do
  mkdir $year
  for month in {01..12}
  do
    mkdir $year/$month
    for file_number in {001..007}
    do
      echo Файл $file_number > $year/$month/$file_number.txt
    done
  done
done

### 3. * Использовать команду AWK на вывод длинного списка каталога, чтобы отобразить только права доступа к файлам. Затем отправить в конвейере этот вывод на sort и uniq, чтобы отфильтровать все повторяющиеся строки.

ls -l | grep -v '^total' | awk '{print $1} '| sort | uniq

### 4. Используя grep, проанализировать файл /var/log/syslog, отобрав события на своё усмотрение.

# Сортируем по слову cron
grep -i cron /var/log/syslog
cat /var/log/syslog | grep -i cron

### 5. Создать разовое задание на перезагрузку операционной системы, используя at.

# Вариант 1
echo sudo reboot | at 1:51pm 12/03/2020

# Вариант 2
sudo at -f /home/nail/reboot.sh 9:00 tomorrow

cat reboot.sh
#!/bin/bash
sudo reboot

### 6. * Написать скрипт, делающий архивную копию каталога etc, и прописать задание в crontab.

vim backup.sh

#!/bin/bash
tar -czf /home/ubuntu/etc_arhived.tar.gz /etc

crontab -e
55 23 * * * /home/ubuntu/backup.sh


# Репозитории и управление репозиториями
# Добавление репозитория через редактирование файла /etc/apt/sources.list 

# Переходим в папку /etc/apt/
cd /etc/apt/

# Добавляем в конец строку новго репозитория для nginx
deb http://nginx.org/packages/ubuntu focal nginx

# Добавим ключ, который используется для проверки  
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -

# Выполняем обновление источников репозиториев
sudo apt update 

# Устанавливаем nginx уже из нужного репозитория
apt install nginx

# Добавление репозитория, используя команду apt-add-repository
sudo apt-add-repository ppa:nginx/stable 


# Управление пакетами через утилиту apt
# Поиск пакета
sudo apt search zip
sudo apt search zip | grep "^zip" 

# Посмотреть информацию о пакете
sudo apt show zip

# Установить пакет
sudo apt install zip -y
zip --version

# Удалить пакет, при этом сохранятся файлы с настройками
sudo apt remove zip

# Полностью удалить пакет, включая конфигурационные файлы
sudo apt purge zip

# Обновить информацию о пакетах в репозиториях, указанных в настройках
sudo apt update

# Обновить все установленные пакеты
sudo apt upgrade


# Управление пакетами через утилиту dpkg
# Просмотр списка пакетов
sudo dpkg -l
sudo dpkg -l | grep p7zip

# Установить пакет или группу пакетов
# Скачиваем нужный пакет
wget http://archive.ubuntu.com/ubuntu/pool/universe/p/p7zip/p7zip-full_16.02+dfsg-7build1_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/p/p7zip/p7zip_16.02+dfsg-7build1_amd64.deb


# Устанавливаем
sudo dpkg -i p7zip-full_16.02+dfsg-7build1_amd64.deb
sudo dpkg -i p7zip_16.02+dfsg-7build1_amd64.deb

# удалить пакет или группу пакетов
sudo dpkg -r p7zip


# Управление пакетами через утилиту snap
# Поиск пакета
snap search p7zip

# Установка пакета
snap install p7zip-desktop

# Обновление пакета
snap refresh p7zip-desktop

# Удаление пакета
snap remove p7zip-desktop

# Просмотр установленных пакетов
snap list


# Основы сетевой безопасности
# Сетевой фильтр
# СОздаём простой пример конфигурации
nano new_iptables.rules

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

# Но если работаем как сервер SSH, следует разрешить и нужные порты
iptables -A INPUT -i eth0 -p tcp -m tcp --dport 22 -j ACCEPT 
iptables -A OUTPUT -o eth0 -p tcp -m tcp --sport 22 -j ACCEPT
sud 
chmod +x new_iptables.rules

# Сохранение фильтра в файл
sudo iptables-save > ./iptables.rules

# Восстановление фильтра 
sudo iptables-restore < ./iptables.rules







