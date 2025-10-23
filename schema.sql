
CREATE TABLE customer (
    id_customer SERIAL PRIMARY KEY,
    nama_customer VARCHAR(100),
    no_hp_customer VARCHAR(20),
    asal VARCHAR(100),
    alamat_lengkap_asal VARCHAR(200)
);

CREATE TABLE harga (
    id_harga SERIAL PRIMARY KEY,
    id_kategori INTEGER REFERENCES kategori(id_kategori),
    harga NUMERIC(12,2)
);

CREATE TABLE kota (
    id_kota SERIAL PRIMARY KEY,
    kota VARCHAR(100)
);

CREATE TABLE kategori (
    id_kategori SERIAL PRIMARY KEY,
    kategori VARCHAR(100)
);

CREATE TABLE jenis (
    id_jenis SERIAL PRIMARY KEY,
    jenis_pengiriman VARCHAR(100)
);

CREATE TABLE metode (
    id_metode SERIAL PRIMARY KEY,
    metode_pembayaran VARCHAR(100)
);

CREATE TABLE kurir (
    id_kurir SERIAL PRIMARY KEY,
    nama_kurir VARCHAR(100),
    no_hp_kurir VARCHAR(20),
    plat_kendaraan VARCHAR(20)
);

CREATE TABLE users (
    id_user SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(100)
);

CREATE TABLE transaksi (
    no_resi VARCHAR(50) PRIMARY KEY,
    id_customer INTEGER REFERENCES customer(id_customer),
    id_harga INTEGER REFERENCES harga(id_harga),
    id_jenis INTEGER REFERENCES jenis(id_jenis),
    id_kategori INTEGER REFERENCES kategori(id_kategori),
    id_metode INTEGER REFERENCES metode(id_metode),
    id_kota_asal INTEGER REFERENCES kota(id_kota),
    id_kota_tujuan INTEGER REFERENCES kota(id_kota),
    berat NUMERIC(8,2),
    total NUMERIC(12,2),
    alamat_lengkap_tujuan VARCHAR(200),
    tanggal_pengiriman DATE,
    id_kurir INTEGER REFERENCES kurir(id_kurir)
);
