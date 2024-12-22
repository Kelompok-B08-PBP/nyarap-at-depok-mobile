# Nyarap @Depok🍳 Mobile

### Kelompok B08:
- Alisha Aline Athiyyah - 2306207921
- Dhafin Putra Nugraha - 2306221112
- Maira Shasmeen Mazaya - 2306245724
- Naila Syarifa Yosarvi - 2306245882
- Valiza Nadya Jatikansha - 2306240156

### Visi:
Mempermudah warga Depok dalam menemukan tempat sarapan yang cepat, enak, dan sesuai selera.

### Misi:
- Memberikan rekomendasi tempat sarapan berdasarkan preferensi pengguna.
- Menyediakan platform untuk pengguna menulis ulasan dan memberikan rating tempat sarapan.

### Masalah yang Ingin Ditangani:
Aplikasi ini dirancang untuk membantu mengatasi kebingungan warga Depok dalam mencari sarapan, terutama bagi mereka yang baru pindah atau memiliki waktu terbatas. Aplikasi ini menyediakan informasi mengenai tempat sarapan yang sesuai dengan preferensi pengguna.

### Siapa yang Terbantu:
- Mahasiswa baru atau orang-orang yang baru pindah ke Depok.
- Pekerja kantoran yang membutuhkan sarapan cepat sebelum memulai hari.
- Warga lokal yang gemar mencoba berbagai jenis sarapan dan ingin berbagi ulasan.

### Bagaimana Cara Membantu:
Aplikasi ini memberikan pilihan tempat sarapan yang beragam melalui fitur pencarian, rekomendasi, ulasan, forum aktivitas, dan rating. Pengguna dapat menyimpan tempat favorit mereka dalam wishlist sehingga dapat merencanakan sarapan berikutnya.

---

## Fitur Utama:

### 1. Landing Page:
- **Login & Sign Up**
- **Welcoming**
- **Deskripsi**
- **Modul:** Rekomendasi Nyarap, Nyarap Detailer

### 2. Home Page:
- **Welcoming**
- **Deskripsi**
- **Modul:** Rekomendasi Nyarap, Nyarap Activity, Nyarap Detailer, Nyarap Favorit, Nyarap Ulasan
- **FAQ**

---

## Modul

### 1. Rekomendasi Nyarap 🍽️ (Discover) 
Pada modul ini, pengguna dapat mengisi form untuk mendapatkan rekomendasi tempat sarapan yang sesuai dengan preferensi makanan dan lokasi mereka. Untuk pengembangan tambahan, fitur penyimpanan form preferensi pengguna dapat ditambahkan ke dalam "History," sehingga pengguna dapat melihat kembali preferensi sebelumnya, serta mengedit atau menghapus data yang tersimpan.
Dikerjakan oleh Valiza Nadya Jatikansha

### 2. Nyarap Activity 🧑🏼‍💻 (Community)
Pengguna dapat memposting aktivitas dan status terkait sarapan mereka di berbagai tempat. Mereka dapat membagikan informasi tentang tempat sarapan yang dikunjungi, menyertakan foto makanan, serta lokasi yang dapat diakses secara publik.
Dikerjakan oleh Naila Syarifa Yosarvi

### 3. Nyarap Detailer 🍲 (Details)
Pengguna dapat melihat informasi lengkap terkait tempat sarapan, termasuk menu, jam operasional, alamat, foto, ulasan, komentar pengguna, dan rating. Pengguna juga dapat menambahkan informasi tambahan pada setiap produk di tempat sarapan.
Dikerjakan oleh Dhafin Putra Nugraha

### 4. Nyarap Nanti ❤️ (Wishlist)
Pengguna dapat dengan mudah menyimpan tempat sarapan favorit mereka ke dalam wishlist pribadi, lengkap dengan fitur untuk menambahkan catatan khusus pada setiap tempat favorit mereka.
Dikerjakan oleh Alisha Aline Athiyyah

### 5. Nyarap Ulasan 📝 (Reviews)
Pengguna dapat memberikan ulasan dan rating terkait tempat sarapan yang telah dikunjungi. Ulasan ini membantu pengguna lain dalam memilih tempat sarapan terbaik.
Dikerjakan oleh Maira Shasmeen Mazaya

---

## Role Pengguna:

### Regular User ☝️ (Guest)
- Akses ke fitur Rekomendasi Nyarap, Nyarap Detailer, dan Nyarap Activity.
- Tidak dapat menyimpan tempat dalam wishlist atau memberikan ulasan serta memposting aktivitas.

### Registered User 👥
- Akses penuh ke semua fitur, termasuk Nyarap Nanti untuk menyimpan tempat sarapan dan merencanakan kunjungan.
- Dapat memberikan rating dan ulasan, serta menggunakan fitur Nyarap Activity untuk memposting aktivitas sarapan, berbagi foto, dan lokasi.

---
## Alur Pengintegrasian

1. **Konversi Model Django ke JSON**  
   Model yang telah didefinisikan di Django akan dikonversi ke dalam format JSON. Proses ini memungkinkan data dapat digunakan oleh aplikasi Flutter. JSON adalah format standar yang digunakan untuk bertukar data antara backend dan frontend.

2. **Implementasi REST API di Django**  
   REST API dibuat menggunakan Django REST Framework (DRF) atau dengan memanfaatkan `JsonResponse` dan Django JSON Serializer di file `views.py`. API ini bertugas untuk mengelola data seperti pembuatan, pembaruan, pengambilan, atau penghapusan data dari database Django.

3. **Fitur Log In dan Sign Up di Django**  
   Backend Django dilengkapi dengan endpoint untuk fitur autentikasi, seperti Log In dan Sign Up. Endpoint ini memungkinkan pengguna untuk mendaftar atau masuk ke aplikasi, dengan data pengguna disimpan dan divalidasi di backend.

4. **Request Data dari Flutter ke API Django**  
   Aplikasi Flutter akan mengirimkan request ke URL endpoint Django untuk mengambil atau mengirimkan data. Data yang diterima dari Django kemudian diolah di Flutter untuk ditampilkan kepada pengguna atau disimpan sesuai kebutuhan.

5. **Pembuatan Desain Front-End Flutter**  
   Desain antarmuka Flutter disesuaikan dengan desain website yang sudah dibuat menggunakan Django. Tujuannya adalah menciptakan pengalaman pengguna yang konsisten antara aplikasi mobile dan website.

6. **Implementasi Asynchronous HTTP di Django**  
   Django menggunakan konsep asynchronous HTTP untuk menangani permintaan dari aplikasi Flutter secara efisien. Pendekatan ini memastikan backend dapat merespons permintaan dengan cepat tanpa menghambat proses lainnya.