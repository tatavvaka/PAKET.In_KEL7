-- Audit semantic consistency between the transaction item label and its category.
-- This report lists item labels assigned to more than one master category.
SELECT
    t.barang,
    COUNT(*) AS jumlah_transaksi,
    COUNT(DISTINCT t.id_kategori) AS jumlah_kategori,
    STRING_AGG(DISTINCT k.kategori, ', ' ORDER BY k.kategori) AS kategori_terpakai
FROM transaksi AS t
JOIN kategori AS k ON k.id_kategori = t.id_kategori
GROUP BY t.barang
HAVING COUNT(DISTINCT t.id_kategori) > 1
ORDER BY jumlah_kategori DESC, t.barang;
