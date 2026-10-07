# GateLand- Aplikasi Pengelolaan Perumahan Terpadu 

GateLand adalah sistem manajemen perumahan digital yang dirancang untuk menggantikan proses administrasi manual yang lambat dan rentan kesalahan (seperti pencatatan iuran via spreadsheet dan komunikasi via WhatsApp)[cite: 14, 16, 17]. 

Proyek ini dibangun untuk menghubungkan Pengelola Properti dan Warga melalui dua ekosistem yang terintegrasi: **Dashboard Web (Admin)** dan **Mobile Application (Warga)**[cite: 12].

## 👥 Tim Pengembang (Joker Team)
Proyek UTS ini dirancang dan dikembangkan oleh:
1. **Sabila Rahma Aulia** (253140707111120)
2. **Bunga Fienya Rochma** (253140707111091)
3. **Clara Tri Dianingsih** (253140707111112)


## Fitur Utama & Ruang Lingkup Proyek

Sistem GateLand dirancang dengan arsitektur informasi yang komprehensif untuk dua jenis pengguna utama

### 1. Mobile Application (Portal Warga)
Aplikasi berbasis *mobile* bagi warga (seperti Ibu Rumah Tangga) untuk mengakses informasi iuran, melakukan pembayaran, dan menerima pengumuman secara mandiri
*   **Autentikasi (Portal Warga):** Layar Login dan Registrasi interaktif (Identitas Diri Penghuni) yang dilengkapi validasi form dan *Error State* pencegah frustrasi pengguna
*   **Dashboard Interaktif:** Menampilkan total tagihan iuran aktif, daftar Pengumuman Terbaru, dan Agenda Warga (seperti Kerja Bakti dan Posyandu) dalam format Card UI yang rapi
*   **Manajemen Tagihan & Pembayaran:** 
    *   Daftar Rincian Iuran dengan filter status (Semua, Menunggu, Sudah Lunas)
    *   Formulir konfirmasi pembayaran yang mendukung berbagai metode (QRIS, Virtual Account, Transfer Manual) dilengkapi fitur unggah bukti transfer
    *   Cetak E-Kwitansi resmi dalam format PDF saat pembayaran berhasil diverifikasi
*   **Pusat Notifikasi & Profil:** Riwayat aktivitas warga dan pusat pengaturan data hunian (Blok/Nomor Rumah)

### 💻 2. Dashboard Web (Portal Pengelola/Admin)
Aplikasi berbasis *web* yang ditujukan bagi Manajer Properti untuk memantau administrasi kompleks perumahan
*   **Simulasi Login Admin:** Akses masuk aman khusus pengurus/pengelola RT
*   **Ringkasan Dasbor:** Menampilkan *insight* operasional berupa Total Iuran, daftar Pembayaran Lunas, dan Pembayaran Belum Lunas
*   **Kelola Data Terpusat:** Antarmuka pengelola untuk membuat tagihan iuran baru, mengatur nominal/jatuh tempo, serta menambah atau memverifikasi data penghuni

---

## 🤖 Rancangan Pengembangan AI: Asisten "Gita"
Sebagai bentuk pemenuhan kriteria inovasi UTS, proyek ini merancang implementasi **Gita (GateLand Interactive Assistant)** pada fase *development* selanjutnya 

Antarmuka Chatbot Gita telah disimulasikan sebagai sarana interaktivitas input/output awal[cite: 12]. Ke depannya, Gita akan diintegrasikan dengan model *Natural Language Processing* (NLP) untuk:
1. Menjawab pertanyaan warga seputar rincian tagihan secara otomatis (24/7).
2. Memandu alur tata cara metode pembayaran (seperti panduan transfer bank).
3. Mengumpulkan dan mengkategorikan laporan/keluhan warga terkait fasilitas umum perumahan untuk langsung diteruskan ke dasbor admin.

---

## 🛠️ Teknologi & Tools
*   **Mobile Frontend:** Flutter (Dart)
*   **Web Frontend:** React.js
*   **Data Handling:** Pengelolaan *state* lokal dan *dummy data* / *mock JSON* (tanpa ketergantungan *database* eksternal untuk keperluan purwarupa/MVP).
*   **UI/UX Design:** Figma (Prototyping, Wireframing, User Flow)


## ⚙️ Panduan Menjalankan Proyek (Mobile App)

1. Pastikan Anda telah memasang **Flutter SDK** dan emulator (Android/iOS) di perangkat lokal.
2. Lakukan *clone repository* ini:
   ```bash
   git clone [https://github.com/sabilrra/gatelandproject.git](https://github.com/sabilrra/gatelandproject.git)