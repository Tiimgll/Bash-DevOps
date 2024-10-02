#!/bin/bash

# Запрашиваем у пользователя имя проекта
read -p "Введите имя проекта: " PROJECT_NAME

# Проверяем, задана ли переменная PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "Имя проекта не может быть пустым. Попробуйте снова."
    exit 1
fi

# Запрашиваем у пользователя имя сервера
read -p "Введите имя сервера: " SERVER_NAME

# Проверяем, задана ли переменная SERVER_NAME
if [ -z "$SERVER_NAME" ]; then
    echo "Имя сервера не может быть пустым. Попробуйте снова."
    exit 1
fi

# Запрашиваем у пользователя порт
read -p "Введите порт: " PORT

# Проверяем, задана ли переменная PORT
if [ -z "$PORT" ]; then
    echo "Порт не может быть пустым. Попробуйте снова."
    exit 1
fi

# Создаем директорию для проекта
mkdir -p /var/www/$PROJECT_NAME

# Создаем поддиректории backend и frontend
mkdir -p /var/www/$PROJECT_NAME/backend
mkdir -p /var/www/$PROJECT_NAME/frontend

# Создаем директорию для логов nginx и файлы логов
mkdir -p /var/www/$PROJECT_NAME/nginx
touch /var/www/$PROJECT_NAME/nginx/{error.log,access.log}

# Создаем конфигурационный файл nginx
cat <<EOL > /etc/nginx/conf.d/$PROJECT_NAME.conf
server {
    listen 80;
    server_name $SERVER_NAME.sixhands.co;
    access_log /var/www/$PROJECT_NAME/nginx/access.log;
    error_log /var/www/$PROJECT_NAME/nginx/error.log;

    location / {
        proxy_pass http://localhost:$PORT; # Измените это значение на нужный вам адрес
    }
}
EOL

# Проверяем конфигурацию nginx
if nginx -t; then
    echo "Конфигурация nginx корректна. Перезагружаем nginx."
    sudo systemctl reload nginx
else
    echo "Ошибка в конфигурации nginx. Пожалуйста, проверьте конфигурацию."
fi

# Выдаем права на директорию проекта
sudo chown -R gitlab-runner:gitlab-runner /var/www/$PROJECT_NAME
