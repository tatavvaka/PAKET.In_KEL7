# Ekspedisi Database Management System 🚚
Sebuah proyek universitas berbasis PostgreSQL untuk sistem pengiriman ekspedisi bernama Paketin.Proyek ini menampilkan proses normalisasi database, implementasi relasi antar tabel, serta penggunaan 15 query SQL bersarang (nested query) untuk menganalisis data logistik. Selain itu, proyek ini juga mencakup pengujian data dummy berskala besar (10, 100, 1.000, dan 10.000 baris) untuk mengevaluasi efisiensi query dan performa sistem.
# Project Objectives
Tujuan dari proyek ini adalah untuk menyelesaikan tugas UTS dengan fokus pada pengembangan dan analisis sistem basis data ekspedisi. Proyek ini mencakup beberapa aspek utama, yaitu:
1. **Proses Normalisasi:** Melakukan perancangan dan penerapan normalisasi pada struktur database agar data tersimpan secara efisien dan terhindar dari redundansi.
2. **Pembuatan Data Uji (Dummy):** Menghasilkan empat variasi data uji dengan jumlah berbeda (10, 100, 1.000, dan 10.000 baris) sebagai simulasi kondisi database nyata.
3. **Penerapan Nested Query:** Mengembangkan 15 query bersarang yang digunakan untuk kebutuhan analisis dan pencarian data kompleks dalam sistem.
4. **Uji Performa Query:** Melakukan pengujian waktu eksekusi pada setiap query untuk melihat perbandingan kinerja antar dataset dengan ukuran berbeda.
# 🧩 Struktur Database (PDM)
* **Customer** – Menyimpan informasi pelanggan seperti ID pelanggan, nama, nomor HP, asal pengiriman, dan alamat lengkap asal.
* **Harga** – Berisi daftar kategori serta harga pengiriman untuk setiap jenis layanan yang tersedia.
* **Kota** – Menyimpan data kota yang menjadi tujuan maupun asal pengiriman.
* **Transaksi** – Merupakan tabel utama yang mencatat seluruh detail pengiriman, meliputi nomor resi, nama pelanggan, jenis barang, kategori, harga, berat, total biaya, asal, tujuan, alamat lengkap tujuan, metode pembayaran, jenis pengiriman, tanggal pengiriman, dan kurir yang bertugas.
* **Kurir** – Menyimpan data kurir yang mengantarkan paket, termasuk nama, nomor HP, dan plat kendaraan.
* **Jenis** – Berisi jenis layanan pengiriman seperti *Hemat*, *Regular*, *Instant*, dan *Cargo*.
* **Kategori** – Menyimpan kategori barang seperti *Elektronik*, *Dokumen*, *Makanan/Minuman*, *Pakaian*, *Barang Fragile*, dan *Barang Non-Fragile*.
* **Metode** – Menyimpan metode pembayaran yang digunakan pelanggan seperti *COD*, *QRIS*, dan *CASH*.
* **Users** – Menyimpan akun pengguna (admin atau staf) yang memiliki akses untuk mengelola sistem.
![Diagram PDM](pdm.png)



# 🧰 Tech Stack
Proyek ini dibangun menggunakan:
* PostgreSQL — sebagai sistem manajemen basis data utama.
* pgAdmin 4 — untuk visualisasi, pengelolaan database, dan eksekusi query.
* Navicat Premium — untuk koneksi dan pengujian performa query lintas dataset.
* GitHub — sebagai platform kolaborasi dan penyimpanan versi proyek.
# 📂 Repository Contents
*/Nested Query* → Berisi skrip SQL untuk 15 nested query yang digunakan dalam analisis data ekspedisi.

*/10 Data, /100 Data, /1000 Data, /10000 Data* → Tiap folder berisi file .sql berisi data dummy untuk tabel utama seperti Customer, Transaksi, Kurir, Harga, dan lainnya, dengan jumlah data berbeda sesuai skala pengujian.

*/Schema* → Berisi file Schema.sql untuk membuat seluruh struktur tabel pada database Paketin.
# 🧪 How to Run the Tests
* Jalankan file Schema.sql untuk membuat semua struktur tabel.
* Impor data master seperti kategori, jenis pengiriman, metode pembayaran, dan kota.
* Jalankan folder data secara berurutan (mulai dari folder '10 Data', kemudian '100', '1000', dan '10000').
* Setelah mengimpor satu set data (misalnya dari folder '10 Data'), jalankan semua file query yang ada di folder 'Nested Query' untuk melakukan pengujian.
* Catat waktu eksekusi tiap query untuk membandingkan performa berdasarkan jumlah data.
* Setelah selesai menguji satu folder, hapus isi tabel Transaksi dan Customer sebelum melanjutkan ke folder data berikutnya.
* Ulangi proses yang sama untuk folder '100', '1000', dan '10000'.

# Our Team
* Tata Ivanka | 24051214001 @tatavvaka
* Yohana Noviyanti Sianipar | 24051214002 @yohananovi
* Fahriza Salsabila | 24051214019 @frzasalsaa
* Ayu Artha Wulan Ndari | 24051214022
* Azzahra Anggarista Yoan Putri | 24051214032 @ZAYORA






