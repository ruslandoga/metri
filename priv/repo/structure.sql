CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" INTEGER PRIMARY KEY, "inserted_at" TEXT);
CREATE TABLE IF NOT EXISTS "samples" ("name" TEXT NOT NULL, "labels" TEXT NOT NULL, "timestamp" INTEGER NOT NULL, "value" REAL NOT NULL) STRICT;
CREATE INDEX "samples_name_timestamp_index" ON "samples" ("name", "timestamp");
INSERT INTO schema_migrations VALUES(20230509042411,'2023-05-11T03:38:17');
