#!/bin/bash

BOOTCAMP_ANSIBLE_KEY='<your-key>'

# ユーザ作成（ホームディレクトリ作成、sudoグループ追加）
echo "Creating ansible-deploy user..."
adduser --gecos "" --disabled-password ansible-deploy
usermod -aG sudo ansible-deploy

# sudo パスワード不要にする
echo 'ansible-deploy ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ansible-deploy
chmod 440 /etc/sudoers.d/ansible-deploy

# 公開鍵登録
mkdir -p /home/ansible-deploy/.ssh
chmod 700 /home/ansible-deploy/.ssh
echo $BOOTCAMP_ANSIBLE_KEY | sudo tee /home/ansible-deploy/.ssh/authorized_keys

chmod 600 /home/ansible-deploy/.ssh/authorized_keys
chown -R ansible-deploy:ansible-deploy /home/ansible-deploy/.ssh
echo "Completed!"
