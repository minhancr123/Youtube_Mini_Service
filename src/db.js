import sqlite3 from "sqlite3";
import { open } from "sqlite";

let db;

export async function initDB() {
  db = await open({ filename: "results.db", driver: sqlite3.Database });
  await db.exec(`CREATE TABLE IF NOT EXISTS results (
    id TEXT PRIMARY KEY,
    json TEXT
  )`);
}

export async function saveResult(id, data) {
  await db.run("INSERT INTO results (id, json) VALUES (?, ?)", [id, JSON.stringify(data)]);
}

export async function getResult(id) {
  const row = await db.get("SELECT json FROM results WHERE id = ?", [id]);
  return row ? JSON.parse(row.json) : null;
}
