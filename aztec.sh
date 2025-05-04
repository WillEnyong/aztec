#!/bin/bash

# Fungsi untuk menampilkan logo
show_logo() {
echo -e "\e[34m░██╗░░░░░░░██╗██╗░░██╗████████╗███████╗░█████╗░██╗░░██╗\e[0m\n\
\e[34m░██║░░██╗░░██║██║░░██║╚══██╔══╝██╔════╝██╔══██╗██║░░██║\e[0m\n\
\e[34m░╚██╗████╗██╔╝███████║░░░██║░░░█████╗░░██║░░╚═╝███████║\e[0m\n\
\e[37m░░████╔═████║░██╔══██║░░░██║░░░██╔══╝░░██║░░██╗██╔══██║\e[0m\n\
\e[37m░░╚██╔╝░╚██╔╝░██║░░██║░░░██║░░░███████╗╚█████╔╝██║░░██║\e[0m\n\
\e[37m░░░╚═╝░░░╚═╝░░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝░╚════╝░╚═╝░░╚═╝\e[0m"
}

# Tampilkan logo di awal
show_logo

# Cek dan install Docker jika belum ada
if ! command -v docker &> /dev/null
then
    echo "🔧 Docker belum terinstall, memulai instalasi Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "✅ Docker selesai diinstall."
else
    echo "✅ Docker sudah terinstall, skip instalasi."
fi

# Tampilkan logo lagi
show_logo

# Cek dan install Node.js 18 jika belum ada
if ! node -v | grep -q "v18"
then
    echo "🔧 Node.js 18 belum terinstall, memulai instalasi Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "✅ Node.js 18 selesai diinstall."
else
    echo "✅ Node.js 18 sudah terinstall, skip instalasi."
fi

# Tampilkan logo lagi
show_logo

# Membuat folder data volume
mkdir -p /root/aztec-node/data

# Masuk ke folder /root
cd /root

# Membuat folder aztec-node
mkdir -p aztec-node

# Pindah ke folder aztec-node
cd aztec-node

# Minta input dari user
show_logo
read -p "Masukkan ETHEREUM_HOSTS: " ETHEREUM_HOSTS
read -p "Masukkan L1_CONSENSUS_HOST_URLS: " L1_CONSENSUS_HOST_URLS
read -p "Masukkan VALIDATOR_PRIVATE_KEY: " VALIDATOR_PRIVATE_KEY
read -p "Masukkan P2P_IP: " P2P_IP

# Simpan ke file .env
cat > .env <<EOF
ETHEREUM_HOSTS=$ETHEREUM_HOSTS
L1_CONSENSUS_HOST_URLS=$L1_CONSENSUS_HOST_URLS
VALIDATOR_PRIVATE_KEY=$VALIDATOR_PRIVATE_KEY
P2P_IP=$P2P_IP
EOF

# Membuat file docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  node:
    image: aztecprotocol/aztec:0.85.0-alpha-testnet.5
    environment:
      ETHEREUM_HOSTS: \$ETHEREUM_HOSTS
      L1_CONSENSUS_HOST_URLS: \$L1_CONSENSUS_HOST_URLS
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEY: \$VALIDATOR_PRIVATE_KEY
      P2P_IP: \$P2P_IP
      LOG_LEVEL: debug
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet start --node --archiver --sequencer'
    ports:
      - 8080:8080
    volumes:
      - /root/aztec-node/data:/data
    env_file:
      - .env
EOF

# Menjalankan docker-compose
docker compose up -d

echo "✅ Aztec node sedang berjalan di background dengan konfigurasi dari .env."
