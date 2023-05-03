psql \
   --host=localhost \
   --port=5432 \
   --username=postgres \
   --password \
   --dbname=products 


   psql \dt

   --------+--------------------+-------+----------
 public | coffee_ingredients | table | postgres
 public | coffees            | table | postgres
 public | ingredients        | table | postgres
 public | order_items        | table | postgres
 public | orders             | table | postgres
 public | users              | table | postgres

 

     "db_connection": "host=product-db port=5432 user=postgres password=password dbname=products sslmode=disable",
  