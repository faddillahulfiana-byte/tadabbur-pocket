# 📖 Tadabbur Pocket - Panduan Memulai Cepat

Aplikasi Android berbasis Flutter untuk menjaga hafalan Al-Qur'an (Juz 30) dan tadabbur ringkas berbahasa sederhana, terintegrasi dengan backend database gratis Supabase.

---

## 🗄️ Langkah 1: Eksekusi Skema Database di Supabase

1. Buka [Supabase Dashboard](https://supabase.com/dashboard) dan buat proyek gratis baru (pilih region terdekat, misalnya Singapore).
2. Di panel kiri, buka menu **SQL Editor** -> klik **New query**.
3. Buka file [`database_schema.sql`](file:///c:/proyeksi-aplikasi-android/database_schema.sql), salin (copy) seluruh kodenya, dan tempel (paste) ke SQL Editor Supabase.
4. Klik tombol **Run**. Skrip ini otomatis:
   - Membuat 5 tabel: `surahs`, `quotes`, `user_profiles`, `murajaah_logs`, dan `user_favorite_quotes`.
   - Mengaktifkan Row Level Security (RLS) dengan aturan akses yang aman (publik baca surah/quotes, dan akses data privat untuk murajaah & favorit).
   - Mengisi data 37 surah Juz 30 lengkap dengan nomor, nama latin, teks Arab, arti, tema utama, dan poin-poin tadabbur ringkas.
   - Mengisi 27 data awal (seed) quote islami (kombinasi ayat Al-Qur'an dan motivasi ulama).
5. Buka menu **Project Settings -> API**, lalu salin:
   - **Project URL** (contoh: `https://xyzcompany.supabase.co`)
   - **Project API Anon Key** (kunci publik panjang)

---

## 🔐 Langkah 2: Tambahkan GitHub Secrets

Di repositori GitHub Anda:
1. Buka tab **Settings** -> **Secrets and variables** -> **Actions**.
2. Klik tombol **New repository secret**, tambahkan 2 rahasia:
   - Name: `SUPABASE_URL` | Value: *(Project URL dari Supabase)*
   - Name: `SUPABASE_ANON_KEY` | Value: *(Project API Anon Key dari Supabase)*

---

## 🚀 Langkah 3: Push Kode ke GitHub & Unduh APK

Karena Flutter tidak perlu diinstal di laptop Anda, file APK akan di-build secara otomatis oleh GitHub Actions di cloud:

1. Inisialisasi Git dan hubungkan ke repositori GitHub Anda:
   ```bash
   git init
   git add .
   git commit -m "feat: Tadabbur Pocket initial clean implementation"
   git branch -M main
   git remote add origin https://github.com/USERNAME-ANDA/NAMA-REPO-ANDA.git
   git push -u origin main
   ```
2. Buka tab **Actions** di GitHub, amati alur kerja **Build Android APK** berjalan secara otomatis.
3. Setelah workflow selesai dengan status hijau (centang), klik job tersebut dan unduh artefak:
   📦 **`Tadabbur-Pocket-Release-APK`** (berisi file `app-release.apk`).
4. Pindahkan file `.apk` ke ponsel Android Anda dan instal untuk langsung digunakan!

---

## 📱 Ringkasan 4 Fitur Inti yang Tersedia
1. **Supabase Auth (Email & Password)**: Guest mode untuk membaca publik, login modal saat mencatat murajaah dan menyimpan quote favorit.
2. **Daftar Surah Juz 30 & Tadabbur**: 37 surah dengan teks Arab, Latin, arti, tema, dan tadabbur ringkas aplikatif.
3. **Pencatat & Pengingat Murajaah**: Form pencatatan kelancaran hafalan (*Lancar*, *Perlu Diulang*, *Belum Lancar*), riwayat sesi, dan pengingat lokal harian Android.
4. **Quote Islami & Favorit**: Tampilan quote acak di Beranda, penjelajah quote per kategori, tombol bagikan (*share*), dan daftar favorit tersimpan.
