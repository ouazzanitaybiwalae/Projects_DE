
-- duckdb dw.duckdb -c ".read build_dw.sql"

-- step 1
.read create_tables.sql

-- step 2
.read insert_tables.sql

-- step 3: flat mart
.read create_flatMart.sql

