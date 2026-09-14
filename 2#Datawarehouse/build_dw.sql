
-- duckdb dw_marts.duckdb -c ".read build_dw.sql"

-- step 1
.read create_tables.sql

-- step 2
.read insert_tables.sql

-- step 3: flat mart
.read create_flatMart.sql

-- step 4: skills mart
.read create_skills_mart.sql

--step 5: priority roles
.read create_priority_mart.sql

.read update_priority_mart.sql
