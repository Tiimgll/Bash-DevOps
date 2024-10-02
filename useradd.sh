#!/bin/bash

# Запрос имени пользователя
read -p "Enter the username: " USERNAME

# Генерация случайного пароля
PASSWORD=$(openssl rand -base64 12)

# Создание пользователя с домашней директорией
useradd -m -s /bin/bash $USERNAME

# Установка пароля для пользователя
echo "$USERNAME:$PASSWORD" | chpasswd

# Добавление пользователя в группу sudo и docker
usermod -aG sudo $USERNAME
usermod -aG docker $USERNAME

# Настройка sudo без пароля
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME

# Создание .ssh директории и настройка прав
mkdir -p /home/$USERNAME/.ssh
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh

# Генерация SSH-ключей
ssh-keygen -t rsa -b 2048 -f /home/$USERNAME/.ssh/id_rsa -N ""

# Настройка прав для SSH-ключей
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/id_rsa
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/id_rsa.pub
chmod 600 /home/$USERNAME/.ssh/id_rsa
chmod 644 /home/$USERNAME/.ssh/id_rsa.pub

# Добавление публичного ключа в authorized_keys
cat /home/$USERNAME/.ssh/id_rsa.pub > /home/$USERNAME/.ssh/authorized_keys
chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
chmod 600 /home/$USERNAME/.ssh/authorized_keys

# Запрет подключения под root по SSH
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Отключение входа с паролем для всех пользователей
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Перезапуск SSH службы для применения изменений
systemctl reload sshd

# Вывод сгенерированного пароля
echo "User $USERNAME created with password: $PASSWORD"

# Вывод приватного ключа
cat /home/$USERNAME/.ssh/id_rsa
