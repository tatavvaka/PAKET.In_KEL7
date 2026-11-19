-- Verify that transaction totals are derived from the master tariff.
-- This test runs inside a transaction and rolls back all temporary changes.

BEGIN;

INSERT INTO transaksi (
    no_resi, id_customer, id_kategori, id_harga,
    id_kota_asal, id_kota_tujuan, id_metode, id_jenis,
    barang, berat, total, alamat_lengkap_tujuan,
    tanggal_pengiriman, id_kurir
)
SELECT
    'CI-PRICE-TRIGGER',
    (SELECT MIN(id_customer) FROM customer),
    h.id_kategori,
    h.id_harga,
    (SELECT MIN(id_kota) FROM kota),
    (SELECT MIN(id_kota) FROM kota),
    (SELECT MIN(id_metode) FROM metode),
    (SELECT MIN(id_jenis) FROM jenis),
    'Barang uji CI',
    2.00,
    0.01,
    'Alamat uji CI',
    DATE '2026-01-01',
    NULL
FROM harga AS h
WHERE h.id_harga = (SELECT MIN(id_harga) FROM harga);

DO $$
DECLARE
    v_actual NUMERIC(12,2);
    v_expected NUMERIC(12,2);
BEGIN
    SELECT t.total, ROUND(t.berat * h.harga, 2)
    INTO v_actual, v_expected
    FROM transaksi AS t
    JOIN harga AS h
      ON h.id_harga = t.id_harga
     AND h.id_kategori = t.id_kategori
    WHERE t.no_resi = 'CI-PRICE-TRIGGER';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pricing trigger test row was not inserted';
    END IF;

    IF v_actual IS DISTINCT FROM v_expected THEN
        RAISE EXCEPTION 'Insert trigger failed: total %, expected %', v_actual, v_expected;
    END IF;
END;
$$;

-- Change one master tariff and confirm the existing transaction total follows it.
UPDATE harga
SET harga = harga + 1
WHERE id_harga = (SELECT MIN(id_harga) FROM harga);

DO $$
DECLARE
    v_actual NUMERIC(12,2);
    v_expected NUMERIC(12,2);
BEGIN
    SELECT t.total, ROUND(t.berat * h.harga, 2)
    INTO v_actual, v_expected
    FROM transaksi AS t
    JOIN harga AS h
      ON h.id_harga = t.id_harga
     AND h.id_kategori = t.id_kategori
    WHERE t.no_resi = 'CI-PRICE-TRIGGER';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pricing trigger test row disappeared';
    END IF;

    IF v_actual IS DISTINCT FROM v_expected THEN
        RAISE EXCEPTION 'Master-price update trigger failed: total %, expected %', v_actual, v_expected;
    END IF;
END;
$$;

ROLLBACK;
