-- PAKET.In PostgreSQL schema
-- Run this schema before importing master data and transaction datasets.

CREATE TABLE customer (
    id_customer SERIAL PRIMARY KEY,
    nama_customer VARCHAR(100) NOT NULL,
    no_hp_customer VARCHAR(20),
    asal VARCHAR(100) NOT NULL,
    alamat_lengkap_asal VARCHAR(200)
);

CREATE TABLE kategori (
    id_kategori SERIAL PRIMARY KEY,
    kategori VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE harga (
    id_harga SERIAL PRIMARY KEY,
    id_kategori INTEGER NOT NULL UNIQUE REFERENCES kategori(id_kategori),
    harga NUMERIC(12,2) NOT NULL CHECK (harga >= 0),
    CONSTRAINT uq_harga_id_kategori UNIQUE (id_harga, id_kategori)
);

CREATE TABLE kota (
    id_kota SERIAL PRIMARY KEY,
    kota VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE jenis (
    id_jenis SERIAL PRIMARY KEY,
    jenis_pengiriman VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE metode (
    id_metode SERIAL PRIMARY KEY,
    metode_pembayaran VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE kurir (
    id_kurir SERIAL PRIMARY KEY,
    nama_kurir VARCHAR(100) NOT NULL,
    no_hp_kurir VARCHAR(20),
    plat_kendaraan VARCHAR(20)
);

CREATE TABLE users (
    id_user SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);

CREATE TABLE transaksi (
    no_resi VARCHAR(50) PRIMARY KEY,
    id_customer INTEGER NOT NULL REFERENCES customer(id_customer),
    id_kategori INTEGER NOT NULL,
    id_harga INTEGER NOT NULL,
    id_kota_asal INTEGER NOT NULL REFERENCES kota(id_kota),
    id_kota_tujuan INTEGER NOT NULL REFERENCES kota(id_kota),
    id_metode INTEGER NOT NULL REFERENCES metode(id_metode),
    id_jenis INTEGER NOT NULL REFERENCES jenis(id_jenis),
    barang VARCHAR(100) NOT NULL,
    berat NUMERIC(8,2) NOT NULL CHECK (berat > 0),
    total NUMERIC(12,2) NOT NULL CHECK (total >= 0),
    alamat_lengkap_tujuan VARCHAR(200) NOT NULL,
    tanggal_pengiriman DATE NOT NULL,
    id_kurir INTEGER REFERENCES kurir(id_kurir),
    CONSTRAINT fk_transaksi_harga_kategori
        FOREIGN KEY (id_harga, id_kategori)
        REFERENCES harga(id_harga, id_kategori)
);

-- The composite foreign key guarantees that a transaction uses the tariff
-- assigned to its category. id_kurir remains nullable when no verified
-- courier assignment exists in the source dataset.
