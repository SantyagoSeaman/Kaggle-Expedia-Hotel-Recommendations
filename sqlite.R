library("RSQLite")
db <- dbConnect(SQLite(), dbname="db/test.sqlite")
# dbSendQuery(conn = db,
#             "CREATE TABLE School
#                (SchID INTEGER,
#                 Location TEXT,
#                 Authority TEXT,
#                 SchSize TEXT)")
# field.types <- list(
#     user_location_country = "INTEGER",
#     user_location_region = "INTEGER",
#     user_location_city = "INTEGER",
#     user_id = "INTEGER",
#     is_mobile = "INTEGER",
#     is_package = "INTEGER",
#     channel = "INTEGER",
#     srch_ci = "INTEGER",
#     is_mobile = "INTEGER",
#     is_mobile = "INTEGER",
#     symbol="TEXT",
#     permno="INTEGER",
#     shrcd="INTEGER",
#     prc="REAL",
#     ret="REAL")
#
# dbWriteTable(conn=db, name="orig.train", value="train.csv", row.names=FALSE, header=TRUE, field.types=field.types, nrows = 1000000)
# dbGetQuery(db, "CREATE INDEX IF NOT EXISTS idx_your_table_date_sym ON crsp (date, symbol)")
# dbDisconnect(db)


dbWriteTable(conn=db, name="train", value=train)
dbGetQuery(db, "CREATE INDEX IF NOT EXISTS user_location_country_hotel_country_idx ON train (user_location_country, hotel_country)")
dbGetQuery(db, "SELECT * FROM train LIMIT 1")


dbGetQuery(db, "DROP TABLE train_cluster_qty")
dbGetQuery(conn = db,
            "CREATE TABLE train_cluster_qty
               (user_location_country INTEGER,
                hotel_country INTEGER,
                is_package INTEGER,
                srch_adults_children_flag TEXT,
                hotel_cluster INTEGER,
                qty INTEGER,
                frq DOUBLE DEFAULT 0
           )")
dbGetQuery(db, "INSERT INTO train_cluster_qty (user_location_country, hotel_country, is_package, srch_adults_children_flag, hotel_cluster, qty)
           SELECT user_location_country, hotel_country, is_package, srch_adults_children_flag, hotel_cluster, COUNT(*)
           FROM train
           GROUP BY user_location_country, hotel_country, is_package, srch_adults_children_flag, hotel_cluster")
dbGetQuery(db, "CREATE INDEX IF NOT EXISTS user_location_country_hotel_country_idx ON train_cluster_qty
           (user_location_country, hotel_country)")
zzz <- dbGetQuery(db, "SELECT * FROM train_cluster_qty LIMIT 10")
zzz <- dbGetQuery(db, "SELECT SUM(qty) FROM train_cluster_qty WHERE user_location_country = 205 AND hotel_country = 50")

dbGetQuery(db, "UPDATE train_cluster_qty SET frq = qty/(SELECT SUM(qty) FROM train_cluster_qty AS tt
           WHERE tt.user_location_country = train_cluster_qty.user_location_country
                AND tt.hotel_country = train_cluster_qty.hotel_country
                AND tt.is_package = train_cluster_qty.is_package
                AND tt.srch_adults_children_flag = train_cluster_qty.srch_adults_children_flag)")

Sys.time()

dbDisconnect(db)


table(train[train$hotel_market == 191, 'hotel_cluster'])



