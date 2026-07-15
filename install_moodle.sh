#!/bin/bash

# ==============================================================================
# SKRIP INSTALASI DAN OPTIMASI MOODLE OTOMATIS
# Lingkungan: Ubuntu 24.04 LTS (Noble Numbat)
# Stack: Apache2 (MPM Event) + PHP 8.3-FPM + MariaDB + Redis/Memcached
# ==============================================================================

# Hentikan skrip jika terjadi error (kecuali ditangani secara eksplisit)
set -e

# ==============================================================================
# 1. VARIABEL KONFIGURASI (Sesuaikan di sini jika diperlukan)
# ==============================================================================
MOODLE_VERSION="MOODLE_502_STABLE"
MOODLE_DIR="/var/www/moodle"
MOODLE_DATA_DIR="/var/www/moodledata"

DB_NAME="db_moodle"
DB_USER="usr_moodle"
DB_PASS="pwd_moodle"

ADMIN_USER="adminlms"
ADMIN_PASS="Merdeka@1945"
ADMIN_EMAIL="adminlms@smkyasmida.sch.id"
SITE_NAME="LMS TJKT SMKS YASMIDA"
SITE_SHORT="TJKT"
SERVER_IP="192.168.255.250"

# ==============================================================================
# 2. PEMERIKSAAN HAK AKSES ROOT
# ==============================================================================
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Skrip ini harus dijalankan sebagai root (gunakan sudo)."
  exit 1
fi

echo "✅ Hak akses root terverifikasi. Memulai instalasi..."
sleep 2

# ==============================================================================
# 3. PERSIAPAN SISTEM DAN REPOSITORI
# ==============================================================================
echo "🔄 [1/8] Mengonfigurasi SSH dan Repositori..."
# Konfigurasi SSH
sed -i 's/^#Port 22/Port 22/' /etc/ssh/sshd_config || true
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config || true
grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Repositori Cloudeka
cat << 'EOF' > /etc/apt/sources.list.d/ubuntu.sources
Types: deb
URIs: http://cdn.repo.cloudeka.id/ubuntu/
Suites: noble noble-updates noble-backports noble-security noble-proposed
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

# Update dan Upgrade Sistem
apt update
apt upgrade -y
apt autoremove -y
echo "✅ Sistem diperbarui. (Catatan: Reboot manual disarankan jika kernel diperbarui, namun skrip akan melanjutkan)."

# ==============================================================================
# 4. INSTALASI DAN KONFIGURASI APACHE2
# ==============================================================================
echo "🔄 [2/8] Menginstal dan mengonfigurasi Apache2..."
apt install -y apache2 libapache2-mod-fcgid

a2enmod proxy_fcgi setenvif rewrite headers expires
a2dismod mpm_prefork || true
a2enmod mpm_event

# Optimasi apache2.conf
cat << 'EOF' >> /etc/apache2/apache2.conf
KeepAlive On
MaxKeepAliveRequests 200
KeepAliveTimeout 3
Timeout 60
ServerTokens Prod
ServerSignature Off
EOF

# Optimasi mpm_event.conf
cat << 'EOF' > /etc/apache2/mods-available/mpm_event.conf
<IfModule mpm_event_module>
    StartServers             3
    MinSpareThreads         75
    MaxSpareThreads        250
    ThreadsPerChild         50
    MaxRequestWorkers      200
    MaxConnectionsPerChild 10000
</IfModule>
EOF

# Virtual Host Moodle
cat << EOF > /etc/apache2/sites-available/moodle.conf
<VirtualHost *:80>
    ServerName ${SERVER_IP}
    DocumentRoot ${MOODLE_DIR}/public

    <Directory ${MOODLE_DIR}/public>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php
        FallbackResource /r.php
    </Directory>

    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php8.3-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/moodle-error.log
    CustomLog \${APACHE_LOG_DIR}/moodle-access.log combined
</VirtualHost>
EOF

a2ensite moodle.conf
a2dissite 000-default.conf || true
apache2ctl configtest

# ==============================================================================
# 5. INSTALASI DAN KONFIGURASI PHP 8.3
# ==============================================================================
echo "🔄 [3/8] Menginstal dan mengonfigurasi PHP 8.3-FPM..."
apt install -y php8.3-fpm php8.3-cli php8.3-curl php8.3-zip php8.3-gd php8.3-xml \
  php8.3-intl php8.3-mbstring php8.3-redis php8.3-soap php8.3-bcmath \
  php8.3-exif php8.3-ldap php8.3-mysql php8.3-opcache php8.3-readline \
  php8.3-imagick php8.3-xmlrpc php8.3-apcu

# Fungsi untuk memperbarui nilai php.ini (menangani baris yang dikomentari atau tidak)
update_php_ini() {
    local file=$1
    local key=$2
    local value=$3
    sed -i "s/^;*\s*${key}\s*=\s*.*/${key} = ${value}/" "$file"
    # Jika baris tidak ada sama sekali, tambahkan di akhir
    grep -q "^${key} = ${value}" "$file" || echo "${key} = ${value}" >> "$file"
}

for ini_file in /etc/php/8.3/fpm/php.ini /etc/php/8.3/cli/php.ini; do
    update_php_ini "$ini_file" "memory_limit" "512M"
    update_php_ini "$ini_file" "max_execution_time" "300"
    update_php_ini "$ini_file" "max_input_vars" "5000"
    update_php_ini "$ini_file" "upload_max_filesize" "256M"
    update_php_ini "$ini_file" "post_max_size" "256M"
    update_php_ini "$ini_file" "date.timezone" "Asia/Jakarta"
done

# Konfigurasi PHP-FPM Pool
cat << 'EOF' > /etc/php/8.3/fpm/pool.d/www.conf
[www]
user = www-data
group = www-data
listen = /run/php/php8.3-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
listen.backlog = 65535
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 15
pm.max_requests = 500
request_terminate_timeout = 300s
rlimit_files = 65536
request_slowlog_timeout = 5s
slowlog = /var/log/php/8.3/fpm-slow.log
catch_workers_output = yes
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

# Konfigurasi OPcache & APCu
cat << 'EOF' > /etc/php/8.3/fpm/conf.d/99-opcache.ini
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=32
opcache.max_accelerated_files=20000
opcache.revalidate_freq=60
opcache.save_comments=1
EOF

cat << 'EOF' > /etc/php/8.3/fpm/conf.d/20-apcu.ini
extension=apcu
apc.enabled=1
apc.enable_cli=1
apc.shm_size=256M
apc.ttl=7200
apc.gc_ttl=3600
apc.entries_hint=4096
apc.slam_defense=0
apc.serializer=php
EOF

systemctl enable --now php8.3-fpm
systemctl reload php8.3-fpm

# ==============================================================================
# 6. INSTALASI DAN KONFIGURASI MARIADB
# ==============================================================================
echo "🔄 [4/8] Menginstal dan mengonfigurasi MariaDB..."
apt install -y mariadb-server mariadb-client
systemctl enable --now mariadb

# Buat Database dan User
mariadb -u root -e "
CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
"

# Optimasi MariaDB
cat << 'EOF' >> /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
innodb_buffer_pool_size = 2G
innodb_buffer_pool_instances = 2
max_connections = 250
thread_cache_size = 32
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
tmp_table_size = 64M
max_heap_table_size = 64M
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
innodb_file_per_table = 1
innodb_file_format = Barracuda
innodb_large_prefix = 1
EOF

# ==============================================================================
# 7. INSTALASI KODE MOODLE DAN DEPENDENSI
# ==============================================================================
echo "🔄 [5/8] Mengunduh Moodle dan menginstal dependensi..."
apt install -y unzip ufw nano graphviz aspell git clamav ghostscript composer

git clone -b ${MOODLE_VERSION} https://github.com/moodle/moodle.git ${MOODLE_DIR}
chown -R www-data:www-data ${MOODLE_DIR}

mkdir -p /var/www/.cache/composer
chown -R www-data:www-data /var/www/.cache/composer
chmod -R 750 /var/www/.cache/composer

sudo -u www-data composer install --no-dev --classmap-authoritative --working-dir=${MOODLE_DIR}
chown -R www-data:www-data ${MOODLE_DIR}/vendor
chmod -R 755 ${MOODLE_DIR}

# Buat moodledata
mkdir -p ${MOODLE_DATA_DIR}
chown -R www-data:www-data ${MOODLE_DATA_DIR}
find ${MOODLE_DATA_DIR} -type d -exec chmod 700 {} \;
find ${MOODLE_DATA_DIR} -type f -exec chmod 600 {} \;

# Konfigurasi Cron
(crontab -u www-data -l 2>/dev/null || true; echo "* * * * * /usr/bin/php ${MOODLE_DIR}/admin/cli/cron.php >/dev/null 2>&1") | crontab -u www-data -

# ==============================================================================
# 8. INSTALASI INTI MOODLE VIA CLI
# ==============================================================================
echo "🔄 [6/8] Menjalankan instalasi inti Moodle (CLI)..."
# Longgarkan izin sementara untuk installer
chmod -R 0777 ${MOODLE_DIR}
systemctl restart apache2 php8.3-fpm mariadb

sudo -u www-data /usr/bin/php ${MOODLE_DIR}/admin/cli/install.php \
  --lang=id \
  --wwwroot=http://${SERVER_IP} \
  --dataroot=${MOODLE_DATA_DIR} \
  --dbtype=mariadb \
  --dbname=${DB_NAME} \
  --dbuser=${DB_USER} \
  --dbpass=${DB_PASS} \
  --fullname="${SITE_NAME}" \
  --shortname="${SITE_SHORT}" \
  --adminuser=${ADMIN_USER} \
  --adminpass="${ADMIN_PASS}" \
  --adminemail=${ADMIN_EMAIL} \
  --non-interactive \
  --agree-license

# 🔒 Pengerasan Keamanan Pasca-Instalasi (WAJIB)
find ${MOODLE_DIR} -type d -exec chmod 755 {} \;
find ${MOODLE_DIR} -type f -exec chmod 644 {} \;
chmod 640 ${MOODLE_DIR}/config.php
chown root:www-data ${MOODLE_DIR}/config.php

# ==============================================================================
# 9. OPTIMASI CACHING (REDIS & MEMCACHED)
# ==============================================================================
echo "🔄 [7/8] Menginstal dan mengonfigurasi Redis & Memcached..."
apt install -y memcached php8.3-memcached redis-server
systemctl enable --now memcached redis-server

# Konfigurasi Memcached
sed -i 's/^-m .*/-m 256/' /etc/memcached.conf || echo "-m 256" >> /etc/memcached.conf
sed -i 's/^-p .*/-p 11211/' /etc/memcached.conf || echo "-p 11211" >> /etc/memcached.conf
sed -i 's/^-l .*/-l 127.0.0.1/' /etc/memcached.conf || echo "-l 127.0.0.1" >> /etc/memcached.conf
systemctl restart memcached

# Konfigurasi Redis
sed -i 's/^#*supervised .*/supervised systemd/' /etc/redis/redis.conf
sed -i 's/^#*bind .*/bind 127.0.0.1/' /etc/redis/redis.conf
sed -i 's/^#*protected-mode .*/protected-mode yes/' /etc/redis/redis.conf
systemctl restart redis-server

# Sisipkan konfigurasi sesi Redis ke config.php sebelum baris require_once
head -n -2 ${MOODLE_DIR}/config.php > /tmp/config_temp.php
cat << 'EOF' >> /tmp/config_temp.php
$CFG->session_handler_class = '\core\session\redis';
$CFG->session_redis_host = '127.0.0.1';
$CFG->session_redis_port = 6379;
$CFG->session_redis_database = 0;
$CFG->session_redis_prefix = 'moodle_';
$CFG->session_redis_acquire_lock_timeout = 120;
$CFG->session_redis_lock_expire = 7200;

require_once(__DIR__ . '/lib/setup.php');
EOF
mv /tmp/config_temp.php ${MOODLE_DIR}/config.php
chown root:www-data ${MOODLE_DIR}/config.php
chmod 640 ${MOODLE_DIR}/config.php

# ==============================================================================
# 10. FINALISASI
# ==============================================================================
echo "🔄 [8/8] Merestart semua layanan dan memverifikasi..."
systemctl restart apache2 php8.3-fpm mariadb memcached redis-server

echo ""
echo "=============================================================================="
echo "✅ INSTALASI MOODLE BERHASIL DISELESAIKAN!"
echo "=============================================================================="
echo "🌐 URL Akses      : http://${SERVER_IP}"
echo "👤 Admin Username : ${ADMIN_USER}"
echo "🔑 Admin Password : ${ADMIN_PASS}"
echo "=============================================================================="
echo "💡 Langkah Selanjutnya:"
echo "1. Buka browser dan login menggunakan kredensial di atas."
echo "2. Masuk ke: Administrasi Situs > Notifikasi (pastikan tidak ada error)."
echo "3. Masuk ke: Administrasi Situs > Pengembangan > Hapus Cache."
echo "4. (Opsional) Konfigurasi UFW: sudo ufw allow 80/tcp && sudo ufw allow 22/tcp && sudo ufw enable"
echo "=============================================================================="
