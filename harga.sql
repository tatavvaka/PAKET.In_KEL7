-- PAKET.In - MASTER HARGA
-- GitHub master tariffs keyed to kategori.id_kategori.

INSERT INTO "harga" ("id_harga", "id_kategori", "harga") VALUES (1, 1, 20000.00); -- Elektronik
INSERT INTO "harga" ("id_harga", "id_kategori", "harga") VALUES (2, 2, 8000.00);  -- Dokumen
INSERT INTO "harga" ("id_harga", "id_kategori", "harga") VALUES (3, 3, 15000.00); -- Makanan/Minuman
INSERT INTO "harga" ("id_harga", "id_kategori", "harga") VALUES (4, 4, 10000.00); -- Pakaian
INSERT INTO "harga" ("id_harga", "id_kategori", "harga") VALUES (5, 5, 22000.00); -- Barang Fragile
INSERT INTO "harga" ("id_harga", "id_kategori", "harga") VALUES (6, 6, 12000.00); -- Barang Non-Fragile

SELECT setval(pg_get_serial_sequence('harga', 'id_harga'),
              (SELECT MAX(id_harga) FROM harga), true);
