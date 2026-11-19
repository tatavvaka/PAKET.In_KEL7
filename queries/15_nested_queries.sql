-- 15 nested queries for PAKET.In
-- Run after schema.sql, master data, customer data, and transaction data.

-- 01. Transactions with a total cost above the overall average.
SELECT no_resi, berat, total
FROM transaksi
WHERE total > (SELECT AVG(total) FROM transaksi)
ORDER BY total DESC;

-- 02. Customers whose transaction count is above the average customer count.
SELECT c.id_customer, c.nama_customer, COUNT(t.no_resi) AS jumlah_transaksi
FROM customer AS c
LEFT JOIN transaksi AS t ON t.id_customer = c.id_customer
GROUP BY c.id_customer, c.nama_customer
HAVING COUNT(t.no_resi) > (
    SELECT AVG(per_customer.jumlah_transaksi)
    FROM (
        SELECT c2.id_customer, COUNT(t2.no_resi) AS jumlah_transaksi
        FROM customer AS c2
        LEFT JOIN transaksi AS t2 ON t2.id_customer = c2.id_customer
        GROUP BY c2.id_customer
    ) AS per_customer
)
ORDER BY jumlah_transaksi DESC, c.nama_customer;

-- 03. Customers whose total shipping expenditure is above average.
SELECT c.id_customer, c.nama_customer, COALESCE(SUM(t.total), 0) AS total_pengeluaran
FROM customer AS c
LEFT JOIN transaksi AS t ON t.id_customer = c.id_customer
GROUP BY c.id_customer, c.nama_customer
HAVING COALESCE(SUM(t.total), 0) > (
    SELECT AVG(per_customer.total_pengeluaran)
    FROM (
        SELECT c2.id_customer, COALESCE(SUM(t2.total), 0) AS total_pengeluaran
        FROM customer AS c2
        LEFT JOIN transaksi AS t2 ON t2.id_customer = c2.id_customer
        GROUP BY c2.id_customer
    ) AS per_customer
)
ORDER BY total_pengeluaran DESC;

-- 04. Transactions whose weight is above the average weight in the same category.
SELECT t.no_resi, k.kategori, t.barang, t.berat
FROM transaksi AS t
JOIN kategori AS k ON k.id_kategori = t.id_kategori
WHERE t.berat > (
    SELECT AVG(t2.berat)
    FROM transaksi AS t2
    WHERE t2.id_kategori = t.id_kategori
)
ORDER BY k.kategori, t.berat DESC;

-- 05. Destination cities with more shipments than the average across all cities.
SELECT k.id_kota, k.kota, COUNT(t.no_resi) AS jumlah_pengiriman
FROM kota AS k
JOIN transaksi AS t ON t.id_kota_tujuan = k.id_kota
GROUP BY k.id_kota, k.kota
HAVING COUNT(t.no_resi) > (
    SELECT AVG(per_city.jumlah_pengiriman)
    FROM (
        SELECT k2.id_kota, COUNT(t2.no_resi) AS jumlah_pengiriman
        FROM kota AS k2
        LEFT JOIN transaksi AS t2 ON t2.id_kota_tujuan = k2.id_kota
        GROUP BY k2.id_kota
    ) AS per_city
)
ORDER BY jumlah_pengiriman DESC;

-- 06. Payment methods used more often than the average method frequency.
SELECT m.id_metode, m.metode_pembayaran, COUNT(t.no_resi) AS jumlah_transaksi
FROM metode AS m
JOIN transaksi AS t ON t.id_metode = m.id_metode
GROUP BY m.id_metode, m.metode_pembayaran
HAVING COUNT(t.no_resi) > (
    SELECT AVG(per_method.jumlah_transaksi)
    FROM (
        SELECT m2.id_metode, COUNT(t2.no_resi) AS jumlah_transaksi
        FROM metode AS m2
        LEFT JOIN transaksi AS t2 ON t2.id_metode = m2.id_metode
        GROUP BY m2.id_metode
    ) AS per_method
)
ORDER BY jumlah_transaksi DESC;

-- 07. Delivery types whose average shipment weight exceeds the overall average.
SELECT j.id_jenis, j.jenis_pengiriman, AVG(t.berat) AS rata_rata_berat
FROM jenis AS j
JOIN transaksi AS t ON t.id_jenis = j.id_jenis
GROUP BY j.id_jenis, j.jenis_pengiriman
HAVING AVG(t.berat) > (SELECT AVG(berat) FROM transaksi)
ORDER BY rata_rata_berat DESC;

-- 08. Tariff categories whose master price is above the average master tariff.
SELECT k.id_kategori, k.kategori, h.harga
FROM harga AS h
JOIN kategori AS k ON k.id_kategori = h.id_kategori
WHERE h.harga > (SELECT AVG(harga) FROM harga)
ORDER BY h.harga DESC;

-- 09. Transactions whose total is above the average for their delivery type.
SELECT t.no_resi, j.jenis_pengiriman, t.total
FROM transaksi AS t
JOIN jenis AS j ON j.id_jenis = t.id_jenis
WHERE t.total > (
    SELECT AVG(t2.total)
    FROM transaksi AS t2
    WHERE t2.id_jenis = t.id_jenis
)
ORDER BY j.jenis_pengiriman, t.total DESC;

-- 10. Couriers whose assigned shipment count is above the average per courier.
SELECT k.id_kurir, k.nama_kurir, COUNT(t.no_resi) AS jumlah_pengiriman
FROM kurir AS k
LEFT JOIN transaksi AS t ON t.id_kurir = k.id_kurir
GROUP BY k.id_kurir, k.nama_kurir
HAVING COUNT(t.no_resi) > (
    SELECT AVG(per_courier.jumlah_pengiriman)
    FROM (
        SELECT k2.id_kurir, COUNT(t2.no_resi) AS jumlah_pengiriman
        FROM kurir AS k2
        LEFT JOIN transaksi AS t2 ON t2.id_kurir = k2.id_kurir
        GROUP BY k2.id_kurir
    ) AS per_courier
)
ORDER BY jumlah_pengiriman DESC;

-- 11. Customers who have never used the COD payment method.
SELECT c.id_customer, c.nama_customer
FROM customer AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM transaksi AS t
    JOIN metode AS m ON m.id_metode = t.id_metode
    WHERE t.id_customer = c.id_customer
      AND UPPER(m.metode_pembayaran) = 'COD'
)
ORDER BY c.nama_customer;

-- 12. Customers who have shipped to destinations with above-average inbound volume.
SELECT c.id_customer, c.nama_customer
FROM customer AS c
WHERE EXISTS (
    SELECT 1
    FROM transaksi AS t
    WHERE t.id_customer = c.id_customer
      AND t.id_kota_tujuan IN (
          SELECT t2.id_kota_tujuan
          FROM transaksi AS t2
          GROUP BY t2.id_kota_tujuan
          HAVING COUNT(*) > (
              SELECT AVG(per_city.jumlah_pengiriman)
              FROM (
                  SELECT k.id_kota, COUNT(t3.no_resi) AS jumlah_pengiriman
                  FROM kota AS k
                  LEFT JOIN transaksi AS t3 ON t3.id_kota_tujuan = k.id_kota
                  GROUP BY k.id_kota
              ) AS per_city
          )
      )
)
ORDER BY c.nama_customer;

-- 13. Categories that contain at least one shipment heavier than the overall average.
SELECT k.id_kategori, k.kategori
FROM kategori AS k
WHERE EXISTS (
    SELECT 1
    FROM transaksi AS t
    WHERE t.id_kategori = k.id_kategori
      AND t.berat > (SELECT AVG(berat) FROM transaksi)
)
ORDER BY k.kategori;

-- 14. Cities that appear as both shipment origins and destinations.
SELECT k.id_kota, k.kota
FROM kota AS k
WHERE EXISTS (
    SELECT 1
    FROM transaksi AS asal
    WHERE asal.id_kota_asal = k.id_kota
)
AND EXISTS (
    SELECT 1
    FROM transaksi AS tujuan
    WHERE tujuan.id_kota_tujuan = k.id_kota
)
ORDER BY k.kota;

-- 15. Customers whose accumulated shipment weight is above the average per customer.
SELECT c.id_customer, c.nama_customer, COALESCE(SUM(t.berat), 0) AS total_berat
FROM customer AS c
LEFT JOIN transaksi AS t ON t.id_customer = c.id_customer
GROUP BY c.id_customer, c.nama_customer
HAVING COALESCE(SUM(t.berat), 0) > (
    SELECT AVG(per_customer.total_berat)
    FROM (
        SELECT c2.id_customer, COALESCE(SUM(t2.berat), 0) AS total_berat
        FROM customer AS c2
        LEFT JOIN transaksi AS t2 ON t2.id_customer = c2.id_customer
        GROUP BY c2.id_customer
    ) AS per_customer
)
ORDER BY total_berat DESC;
