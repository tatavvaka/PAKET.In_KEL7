#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${PGHOST:=127.0.0.1}"
: "${PGPORT:=5432}"
: "${PGUSER:=postgres}"
: "${PGPASSWORD:=postgres}"
: "${DB_PREFIX:=paketin_ci}"
export PGHOST PGPORT PGUSER PGPASSWORD

command -v psql >/dev/null || { echo "psql is required" >&2; exit 1; }
command -v createdb >/dev/null || { echo "createdb is required" >&2; exit 1; }
command -v dropdb >/dev/null || { echo "dropdb is required" >&2; exit 1; }

assert_query() {
  local db="$1" label="$2" sql="$3" expected="$4" actual
  actual="$(psql -X -A -t -v ON_ERROR_STOP=1 -d "$db" -c "$sql" | tr -d '[:space:]')"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL [%s]: expected %s, got %s\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

for size in 10 100 1000 10000; do
  case "$size" in
    10)
      customer_file="DATA 10/customer.sql"
      transaction_file="DATA 10/transaksi.sql"
      expected_customers=10
      expected_transactions=10
      expected_total="3094000.00"
      expected_null_courier=0
      ;;
    100)
      customer_file="DATA 100/customer100.sql"
      transaction_file="DATA 100/transaksi100.sql"
      expected_customers=100
      expected_transactions=100
      expected_total="36458000.00"
      expected_null_courier=0
      ;;
    1000)
      customer_file="DATA 1000/customer1000.sql"
      transaction_file="DATA 1000/transaksi1000.sql"
      expected_customers=1001
      expected_transactions=1000
      expected_total="405759000.00"
      expected_null_courier=0
      ;;
    10000)
      customer_file="DATA 10000/customer10000.sql"
      transaction_file="DATA 10000/transaksi10000.sql"
      expected_customers=10000
      expected_transactions=10000
      expected_total="3838183000.00"
      expected_null_courier=10000
      ;;
  esac

  db="${DB_PREFIX}_${size}"
  dropdb --if-exists --force "$db" >/dev/null 2>&1 || true
  createdb "$db"

  psql -X -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/schema.sql" >/dev/null
  for master_file in kategori harga kota jenis metode kurir users; do
    psql -X -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/$master_file.sql" >/dev/null
  done
  psql -X -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/$customer_file" >/dev/null
  psql -X -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/$transaction_file" >/dev/null
  psql -X -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/scripts/test_pricing_triggers.sql" >/dev/null
  psql -X -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/scripts/reset_sequences.sql" >/dev/null
  psql -X -q -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/queries/15_nested_queries.sql" >/dev/null
  psql -X -q -v ON_ERROR_STOP=1 -d "$db" -f "$ROOT_DIR/queries/audit_kategori_barang.sql" >/dev/null

  assert_query "$db" "DATA $size transaction count" "SELECT COUNT(*) FROM transaksi" "$expected_transactions"
  assert_query "$db" "DATA $size customer count" "SELECT COUNT(*) FROM customer" "$expected_customers"
  assert_query "$db" "DATA $size price formula" "SELECT COUNT(*) FROM transaksi t JOIN harga h ON h.id_harga=t.id_harga AND h.id_kategori=t.id_kategori WHERE t.total <> t.berat*h.harga" "0"
  assert_query "$db" "DATA $size customer FK" "SELECT COUNT(*) FROM transaksi t LEFT JOIN customer c ON c.id_customer=t.id_customer WHERE c.id_customer IS NULL" "0"
  assert_query "$db" "DATA $size courier NULL count" "SELECT COUNT(*) FROM transaksi WHERE id_kurir IS NULL" "$expected_null_courier"
  assert_query "$db" "DATA $size DATE column type" "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='public' AND table_name='transaksi' AND column_name='tanggal_pengiriman' AND data_type='date'" "1"
  assert_query "$db" "DATA $size SERIAL sequences" "SELECT COUNT(*) FROM (SELECT nextval(pg_get_serial_sequence('public.customer','id_customer')) AS next_id, COALESCE((SELECT MAX(id_customer) FROM customer),0) AS max_id UNION ALL SELECT nextval(pg_get_serial_sequence('public.kategori','id_kategori')), COALESCE((SELECT MAX(id_kategori) FROM kategori),0) UNION ALL SELECT nextval(pg_get_serial_sequence('public.harga','id_harga')), COALESCE((SELECT MAX(id_harga) FROM harga),0) UNION ALL SELECT nextval(pg_get_serial_sequence('public.kota','id_kota')), COALESCE((SELECT MAX(id_kota) FROM kota),0) UNION ALL SELECT nextval(pg_get_serial_sequence('public.jenis','id_jenis')), COALESCE((SELECT MAX(id_jenis) FROM jenis),0) UNION ALL SELECT nextval(pg_get_serial_sequence('public.metode','id_metode')), COALESCE((SELECT MAX(id_metode) FROM metode),0) UNION ALL SELECT nextval(pg_get_serial_sequence('public.kurir','id_kurir')), COALESCE((SELECT MAX(id_kurir) FROM kurir),0) UNION ALL SELECT nextval(pg_get_serial_sequence('public.users','id_user')), COALESCE((SELECT MAX(id_user) FROM users),0)) AS sequence_checks WHERE next_id <= max_id" "0"
  assert_query "$db" "DATA $size total sum" "SELECT COALESCE(SUM(total),0)::numeric(14,2)::text FROM transaksi" "$expected_total"

  echo "PASS: DATA $size imported; $expected_transactions transactions, $expected_customers customers, total Rp $expected_total"
done
