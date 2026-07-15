# 🎓 Moodle High-Performance Server Installer

<div align="center">

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Apache](https://img.shields.io/badge/Apache-2.4-D22128?style=for-the-badge&logo=apache&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?style=for-the-badge&logo=php&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-10.11-00758F?style=for-the-badge&logo=mariadb&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-7.0-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![Moodle](https://img.shields.io/badge/Moodle-5.2-F7941D?style=for-the-badge&logo=moodle&logoColor=white)

**Skrip Otomatis untuk Deployment Server Moodle Berkinerja Tinggi**  
*Optimized for SMKS YASMIDA - TJKT Department*

[📖 Dokumentasi](#-dokumentasi) • [🚀 Instalasi Cepat](#-instalasi-cepat) • [⚙️ Konfigurasi](#️-konfigurasi) • [🐛 Troubleshooting](#-troubleshooting)

</div>

---

## 📋 Deskripsi

Repository ini berisi **skrip instalasi otomatis** dan **panduan konfigurasi manual** untuk membangun server Moodle production-ready dengan stack modern. Dioptimalkan untuk lingkungan pembelajaran dengan beban tinggi, menggunakan caching berlapis (Redis + Memcached) dan web server berkinerja tinggi (Apache2 + PHP-FPM).

### ✨ Fitur Utama

- ⚡ **High Performance** — Apache2 MPM Event + PHP 8.3-FPM
- 🔒 **Production Security** — Hardened configuration & file permissions
- 💾 **Multi-Layer Caching** — Redis (session) + Memcached (app cache)
- 🗄️ **Optimized Database** — MariaDB dengan tuning InnoDB
- 🌏 **Local Mirror** — Menggunakan Cloudeka CDN untuk kecepatan unduh
- 🤖 **Fully Automated** — Satu skrip untuk seluruh proses instalasi
- 🇮🇩 **Bahasa Indonesia** — UI dan timezone default Indonesia

---

## 📚 Daftar Isi

- [Persyaratan Sistem](#-persyaratan-sistem)
- [Arsitektur Stack](#️-arsitektur-stack)
- [Instalasi Cepat](#-instalasi-cepat)
- [Konfigurasi Manual](#️-konfigurasi-manual)
- [Struktur Direktori](#-struktur-direktori)
- [Kredensial Default](#-kredensial-default)
- [Verifikasi Pasca-Instalasi](#-verifikasi-pasca-instalasi)
- [Troubleshooting](#-troubleshooting)
- [Maintenance Commands](#-maintenance-commands)
- [Kontribusi](#-kontribusi)
- [Lisensi](#-lisensi)

---

## 💻 Persyaratan Sistem

| Komponen | Spesifikasi Minimum | Rekomendasi |
|----------|---------------------|-------------|
| **OS** | Ubuntu 24.04 LTS | Ubuntu 24.04 LTS (Clean Install) |
| **CPU** | 2 vCPU | 4+ vCPU |
| **RAM** | 4 GB | 8+ GB |
| **Storage** | 40 GB SSD | 100+ GB NVMe SSD |
| **Network** | 100 Mbps | 1 Gbps |
| **Akses** | Root / Sudo | Full root access |

> [!NOTE]
> Skrip ini dirancang khusus untuk **Ubuntu 24.04 LTS (Noble Numbat)**. Untuk versi Ubuntu lain, penyesuaian repositori dan versi PHP mungkin diperlukan.

---

## 🏗️ Arsitektur Stack

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT BROWSER                        │
└──────────────────────┬──────────────────────────────────┘
                       │ HTTP (Port 80)
                       ▼
┌─────────────────────────────────────────────────────────┐
│              Apache2 (MPM Event)                         │
│         ┌──────────────────────────────┐                │
│         │  mod_proxy_fcgi              │                │
│         └──────────────┬───────────────┘                │
└────────────────────────┼────────────────────────────────┘
                         │ Unix Socket
                         ▼
┌─────────────────────────────────────────────────────────┐
│              PHP 8.3-FPM                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ OPcache  │  │   APCu   │  │  Moodle Application  │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
└────────────────────────┬────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   ┌────────────┐ ┌───────────┐ ┌──────────┐
   │  MariaDB   │ │   Redis   │ │Memcached │
   │  (Data)    │ │ (Session) │ │ (Cache)  │
   └────────────┘ └───────────┘ └──────────┘
```

### Penjelasan Komponen

| Komponen | Peran |
|----------|-------|
| **Apache2 (MPM Event)** | Web server dengan model thread-based untuk konkurensi tinggi |
| **PHP 8.3-FPM** | Process manager PHP yang efisien untuk menangani banyak request |
| **MariaDB** | Database server dengan optimasi InnoDB untuk Moodle |
| **Redis** | Session handler untuk performa login dan sesi pengguna |
| **Memcached** | Application cache untuk data yang sering diakses |
| **OPcache + APCu** | Caching opcode PHP dan data di level server |

---

## 🚀 Instalasi Cepat

### 1️⃣ Persiapan Awal

Pastikan sistem dalam keadaan bersih dan up-to-date:

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

### 2️⃣ Unduh Skrip Instalasi

```bash
# Clone repository ini
git clone https://github.com/abdurrozakskom/install_moodle.git
cd install_moodle
```

### 3️⃣ Jalankan Skrip

```bash
chmod +x install_moodle.sh
sudo ./install_moodle.sh
```

> [!IMPORTANT]
> Proses instalasi memakan waktu **5-15 menit** tergantung kecepatan internet. Jangan interrupt proses!

### 4️⃣ Akses Moodle

Setelah instalasi selesai, buka browser dan akses:

```
http://192.168.255.250
```

---

## ⚙️ Konfigurasi

### Menyesuaikan Variabel Instalasi

Sebelum menjalankan skrip, Anda dapat menyesuaikan variabel di bagian atas file `install_moodle.sh`:

```bash
# ==============================================================================
# VARIABEL KONFIGURASI
# ==============================================================================
MOODLE_VERSION="MOODLE_502_STABLE"
MOODLE_DIR="/var/www/moodle"
MOODLE_DATA_DIR="/var/www/moodledata"

DB_NAME="dbs_moodle"
DB_USER="usr_moodle"
DB_PASS="pwd_moodle"        # ⚠️ Ganti dengan password yang kuat!

ADMIN_USER="adminlms"
ADMIN_PASS="Merdeka@1945"  # ⚠️ Ganti dengan password yang kuat!
ADMIN_EMAIL="adminlms@smkyasmida.sch.id"
SITE_NAME="LMS TJKT SMKS YASMIDA"
SITE_SHORT="TJKT"
SERVER_IP="192.168.255.250"      # Sesuaikan dengan IP server Anda
```

### Konfigurasi Firewall (UFW)

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS (jika menggunakan SSL)
sudo ufw enable
sudo ufw status
```

### Konfigurasi HTTPS (Opsional dengan Let's Encrypt)

```bash
sudo apt install -y certbot python3-certbot-apache
sudo certbot --apache -d yourdomain.com
```

---

## 📂 Struktur Direktori

```
/var/www/
├── moodle/                  # Moodle source code
│   ├── admin/              # Admin scripts
│   ├── lib/                # Core libraries
│   ├── config.php          # Configuration file (640, root:www-data)
│   └── vendor/             # Composer dependencies
├── moodledata/             # Moodle data directory (700, www-data)
│   ├── cache/              # Application cache
│   ├── sessions/           # Session files (jika tidak pakai Redis)
│   └── temp/               # Temporary files
└── .cache/
    └── composer/           # Composer cache
```

### File Konfigurasi Penting

| File | Lokasi | Fungsi |
|------|--------|--------|
| `config.php` | `/var/www/moodle/config.php` | Konfigurasi utama Moodle |
| `apache2.conf` | `/etc/apache2/apache2.conf` | Konfigurasi global Apache |
| `moodle.conf` | `/etc/apache2/sites-available/moodle.conf` | Virtual host Moodle |
| `php.ini` (FPM) | `/etc/php/8.3/fpm/php.ini` | Konfigurasi PHP-FPM |
| `php.ini` (CLI) | `/etc/php/8.3/cli/php.ini` | Konfigurasi PHP CLI |
| `www.conf` | `/etc/php/8.3/fpm/pool.d/www.conf` | Konfigurasi pool PHP-FPM |
| `50-server.cnf` | `/etc/mysql/mariadb.conf.d/50-server.cnf` | Konfigurasi MariaDB |

---

## 🔑 Kredensial Default

> [!WARNING]
> **SEGERA GANTI** kredensial default setelah instalasi pertama untuk keamanan!

| Layanan | Username | Password |
|---------|----------|----------|
| **Moodle Admin** | `adminlms` | `Merdeka@1945` |
| **MariaDB User** | `usr_moodle` | `pwd_moodle` |
| **MariaDB Root** | `root` | *(system auth)* |

### Mengganti Password Moodle Admin

```bash
sudo -u www-data php /var/www/moodle/admin/cli/reset_password.php \
  --username=adminlms
```

### Mengganti Password Database

```bash
sudo mariadb -u root
```
```sql
ALTER USER 'usr_moodle'@'%' IDENTIFIED BY 'new_secure_password';
FLUSH PRIVILEGES;
EXIT;
```

Jangan lupa update password di `/var/www/moodle/config.php`:
```php
$CFG->dbpass = 'new_secure_password';
```

---

## ✅ Verifikasi Pasca-Instalasi

### 1. Cek Status Layanan

```bash
sudo systemctl status apache2 php8.3-fpm mariadb memcached redis-server
```

Semua layanan harus menunjukkan status `active (running)`.

### 2. Verifikasi Moodle Cron

```bash
sudo crontab -u www-data -l
```

Harus menampilkan:
```
* * * * * /usr/bin/php /var/www/moodle/admin/cli/cron.php >/dev/null 2>&1
```

### 3. Uji Koneksi Redis

```bash
redis-cli ping
# Output: PONG
```

### 4. Cek Log Error

```bash
sudo tail -f /var/log/apache2/moodle-error.log
sudo tail -f /var/log/php/8.3/fpm-slow.log
```

### 5. Verifikasi Konfigurasi Moodle

Login sebagai admin, lalu navigasi ke:
- **Site administration → Server → Environment** — Pastikan semua komponen OK
- **Site administration → Development → Purge caches** — Bersihkan cache awal
- **Site administration → Reports → Configuration** — Cek konfigurasi aktif

---

## 🐛 Troubleshooting

### Masalah Umum dan Solusi

<details>
<summary><b>❌ "502 Bad Gateway" saat mengakses Moodle</b></summary>

**Penyebab:** PHP-FPM tidak berjalan atau socket tidak tersedia.

**Solusi:**
```bash
sudo systemctl restart php8.3-fpm
sudo systemctl status php8.3-fpm
ls -la /run/php/php8.3-fpm.sock
```
</details>

<details>
<summary><b>❌ "Database connection failed"</b></summary>

**Penyebab:** MariaDB tidak berjalan atau kredensial salah.

**Solusi:**
```bash
sudo systemctl restart mariadb
sudo mariadb -u jackusr_moodle -p jackdbs_moodle
# Masukkan password: jackpsw_moodle
```
</details>

<details>
<summary><b>❌ "Permission denied" pada moodledata</b></summary>

**Penyebab:** Izin direktori tidak tepat.

**Solusi:**
```bash
sudo chown -R www-data:www-data /var/www/moodledata
sudo find /var/www/moodledata -type d -exec chmod 700 {} \;
sudo find /var/www/moodledata -type f -exec chmod 600 {} \;
```
</details>

<details>
<summary><b>❌ Cron Moodle tidak berjalan</b></summary>

**Penyebab:** Cron job tidak terdaftar atau PHP path salah.

**Solusi:**
```bash
# Cek cron
sudo crontab -u www-data -l

# Jalankan manual untuk testing
sudo -u www-data /usr/bin/php /var/www/moodle/admin/cli/cron.php
```
</details>

<details>
<summary><b>❌ "Memory exhausted" error</b></summary>

**Penyebab:** Memory limit PHP terlalu rendah.

**Solusi:**
```bash
sudo nano /etc/php/8.3/fpm/php.ini
# Ubah: memory_limit = 512M (atau lebih tinggi)
sudo systemctl restart php8.3-fpm
```
</details>

<details>
<summary><b>❌ Halaman blank putih (White Screen of Death)</b></summary>

**Penyebab:** Error PHP yang tidak ditampilkan.

**Solusi:**
```bash
# Aktifkan debug di config.php
$CFG->debug = (E_ALL | E_STRICT);
$CFG->debugdisplay = 1;

# Cek log PHP
sudo tail -f /var/log/php/8.3/fpm-slow.log
```
</details>

### Perintah Debug Berguna

```bash
# Cek konfigurasi Apache
sudo apache2ctl configtest

# Cek konfigurasi PHP
php -i | grep memory_limit

# Lihat log real-time
sudo tail -f /var/log/apache2/moodle-error.log

# Purge cache Moodle via CLI
sudo -u www-data php /var/www/moodle/admin/cli/purge_caches.php

# Cek environment Moodle
sudo -u www-data php /var/www/moodle/admin/cli/cfg.php --name=wwwroot
```

---

## 🔧 Maintenance Commands

### Restart Semua Layanan

```bash
sudo systemctl restart apache2 php8.3-fpm mariadb memcached redis-server
```

### Update Moodle ke Versi Terbaru

```bash
cd /var/www/moodle
sudo -u www-data git pull origin MOODLE_502_STABLE
sudo -u www-data composer install --no-dev
sudo -u www-data php admin/cli/upgrade.php --non-interactive
```

### Backup Database

```bash
sudo mariadb-dump -u jackusr_moodle -p jackdbs_moodle > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
sudo mariadb -u jackusr_moodle -p jackdbs_moodle < backup_20260715.sql
```

### Backup Moodledata

```bash
sudo tar -czvf moodledata_backup_$(date +%Y%m%d).tar.gz /var/www/moodledata
```

### Monitoring Performa

```bash
# Cek penggunaan RAM
free -h

# Cek proses PHP-FPM aktif
ps aux | grep php-fpm

# Cek koneksi MariaDB
mysqladmin -u root status

# Cek Redis stats
redis-cli info stats
```

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buka Pull Request

### Panduan Kontribusi

- Ikuti standar penulisan kode yang sudah ada
- Tambahkan komentar pada bagian kode yang kompleks
- Uji skrip di environment bersih sebelum submit PR
- Update dokumentasi jika ada perubahan fitur

---

## 📄 Lisensi

Distributed under the MIT License. See `LICENSE` for more information.

```
MIT License

Copyright (c) 2026 SMKS YASMIDA - TJKT Department

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 📞 Kontak & Dukungan

**SMKS YASMIDA - Jurusan Teknik Jaringan Komputer dan Telekomunikasi (TJKT)**

| Kontak | Detail |
|--------|--------|
| 📧 Email | abdurrozak.skom@gmail.com |
| 🌐 Website | [smkyasmida.sch.id](http://smkyasmida.sch.id) |
| 📍 Alamat | SMKS YASMIDA, Indonesia |
| 👨‍💻 Maintainer | Tim IT TJKT |

---

## 🙏 Acknowledgments

- [Moodle Project](https://moodle.org) - Learning Management System
- [Ubuntu](https://ubuntu.com) - Operating System
- [Apache](https://apache.org) - Web Server
- [PHP](https://php.net) - Programming Language
- [MariaDB](https://mariadb.org) - Database
- [Redis](https://redis.io) - In-Memory Data Store
- [Memcached](https://memcached.org) - Distributed Caching
- [Cloudeka](https://cloudeka.id) - Local Mirror Repository

---

## 📊 Roadmap

- [x] Instalasi otomatis Moodle 5.2
- [x] Optimasi Apache2 + PHP-FPM
- [x] Integrasi Redis & Memcached
- [x] Hardening keamanan file permissions
- [ ] Dukungan HTTPS otomatis (Let's Encrypt)
- [ ] Skrip backup otomatis terjadwal
- [ ] Monitoring dashboard (Grafana + Prometheus)
- [ ] Dukungan multi-server (load balancer)

---

<div align="center">

**⭐ Jika repository ini membantu, jangan lupa berikan bintang! ⭐**

*Maintained with ❤️ by SMKS YASMIDA - TJKT Department*

**Last Updated:** July 15, 2026

</div>
