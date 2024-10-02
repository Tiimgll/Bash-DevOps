#!/bin/bash

# Обновление и апгрейд системы
sudo apt-get update && sudo apt-get upgrade -y

# Установка необходимых инструментов
sudo apt-get install -y nginx git curl wget ca-certificates

# Установка Certbot для работы с SSL
sudo apt-get install -y certbot python3-certbot-nginx

# Установка Docker и Docker Compose
sudo apt-get install -y apt-transport-https software-properties-common
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Проверка установки Docker
sudo docker run hello-world

# Включение Nginx
sudo systemctl enable --now nginx

# Отключение показа версии Nginx
sed -i "s/# server_tokens off;/server_tokens off;/" /etc/nginx/nginx.conf

# Проверяем конфигурацию Nginx
if nginx -t; then
    echo "Конфигурация nginx корректна. Перезагружаем nginx."
    sudo systemctl reload nginx
else
    echo "Ошибка в конфигурации nginx. Пожалуйста, проверьте конфигурацию."
fi

# Запрос нового порта SSH у пользователя
read -p "Введите новый порт для SSH: " SSH_PORT

# Проверка, что введенный порт является числом
if [[ "$SSH_PORT" =~ ^[0-9]+$ ]]; then
    # Изменение порта в конфигурации SSH
    sudo sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
    sudo sed -i "s/^Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
    
    # Перезапуск SSH для применения изменений
    sudo systemctl reload sshd
    echo "SSH порт изменен на $SSH_PORT"
else
    echo "Введено некорректное значение порта. Порт должен быть числом."
fi

# Сообщение об успешной установке
echo "Установка завершена. Установлены Nginx, Certbot, Docker, git, curl, wget."
