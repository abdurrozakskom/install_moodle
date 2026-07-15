# 🎓 Moodle High-Performance Server Installer

<div align="center">

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04 LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
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
- [Arsitektur Stack](#-arsitektur-stack)
- [Instalasi Cepat](#-instalasi-cepat)
- [Konfigurasi Manual](#️-konfigurasi-manual)
- [Struktur Direktori](#-struktur-direktori)
- [Kredensial Default](#-kredensial-default)
- [Verifikasi Pasca-Instalasi](#-verifikasi-pasca-instalasi)
- [Troubleshooting](#-troubleshooting)
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
