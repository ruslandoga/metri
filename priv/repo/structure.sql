CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" INTEGER PRIMARY KEY, "inserted_at" TEXT);
CREATE TABLE IF NOT EXISTS "samples" ("series_id" INTEGER NOT NULL, "timestamp" INTEGER NOT NULL, "value" REAL NOT NULL, PRIMARY KEY ("series_id","timestamp")) WITHOUT ROWID, STRICT;
CREATE TABLE IF NOT EXISTS "label_to_series" ("name" TEXT NOT NULL, "value" TEXT NOT NULL, "series_id" INTEGER NOT NULL, PRIMARY KEY ("name","value","series_id")) WITHOUT ROWID, STRICT;
INSERT INTO schema_migrations VALUES(20230509042411,'2023-05-09T05:40:47');
