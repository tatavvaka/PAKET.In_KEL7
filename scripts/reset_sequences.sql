-- Reset SERIAL sequences after importing explicit IDs from the seed files.
-- Run this once after importing master data and one transaction dataset.

SELECT setval(pg_get_serial_sequence('public.customer', 'id_customer'),
              COALESCE((SELECT MAX(id_customer) FROM public.customer), 1),
              EXISTS (SELECT 1 FROM public.customer));
SELECT setval(pg_get_serial_sequence('public.kategori', 'id_kategori'),
              COALESCE((SELECT MAX(id_kategori) FROM public.kategori), 1),
              EXISTS (SELECT 1 FROM public.kategori));
SELECT setval(pg_get_serial_sequence('public.harga', 'id_harga'),
              COALESCE((SELECT MAX(id_harga) FROM public.harga), 1),
              EXISTS (SELECT 1 FROM public.harga));
SELECT setval(pg_get_serial_sequence('public.kota', 'id_kota'),
              COALESCE((SELECT MAX(id_kota) FROM public.kota), 1),
              EXISTS (SELECT 1 FROM public.kota));
SELECT setval(pg_get_serial_sequence('public.jenis', 'id_jenis'),
              COALESCE((SELECT MAX(id_jenis) FROM public.jenis), 1),
              EXISTS (SELECT 1 FROM public.jenis));
SELECT setval(pg_get_serial_sequence('public.metode', 'id_metode'),
              COALESCE((SELECT MAX(id_metode) FROM public.metode), 1),
              EXISTS (SELECT 1 FROM public.metode));
SELECT setval(pg_get_serial_sequence('public.kurir', 'id_kurir'),
              COALESCE((SELECT MAX(id_kurir) FROM public.kurir), 1),
              EXISTS (SELECT 1 FROM public.kurir));
SELECT setval(pg_get_serial_sequence('public.users', 'id_user'),
              COALESCE((SELECT MAX(id_user) FROM public.users), 1),
              EXISTS (SELECT 1 FROM public.users));
