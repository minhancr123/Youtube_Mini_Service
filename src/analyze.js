import puppeteer from "puppeteer";
import ytdl from "@distube/ytdl-core";   // ✅ đổi sang fork ổn định hơn
import ffmpeg from "fluent-ffmpeg";
import fs from "fs";
import { v4 as uuidv4 } from "uuid";
import path from "path";
import { transcribe } from "./transcription.js";
import { initDB, saveResult } from "./db.js";
import { detectAI } from "./detectAI.js";

export async function analyzeVideo(url) {
  const id = uuidv4();
  const screenshotPath = path.join("screenshots", `${id}.png`);
  const audioPath = path.join("audio", `${id}.wav`);

  // Tạo thư mục nếu chưa có
  if (!fs.existsSync("screenshots")) {
    fs.mkdirSync("screenshots");
  }
  if (!fs.existsSync("audio")) {
    fs.mkdirSync("audio");
  }

  //  Chụp thumbnail từ YouTube bằng puppeteer
  const browser = await puppeteer.launch({ headless: true }); // hoặc { headless: "new" }
  const page = await browser.newPage();
  await page.goto(url, { waitUntil: "networkidle2" });
  await page.screenshot({ path: screenshotPath });
  await browser.close();

  // 🎵 Tải audio bằng ytdl + ffmpeg
  await new Promise((resolve, reject) => {
    const stream = ytdl(url, { filter: "audioonly", quality: "highestaudio" });
    ffmpeg(stream)
      .audioFrequency(16000)
      .audioChannels(1)
      .audioCodec("pcm_s16le")
      .format("wav")
      .save(audioPath)
      .on("end", () => {
        console.log("Audio extracted:", audioPath);
        resolve(true);
      })
      .on("error", (err) => {
        console.error("ffmpeg error:", err);
        reject(err);
      });
  });

  //transcrip audio
  const transcript = await transcribe(audioPath);
  
  await detectAI(transcript.text)
    .then((result) => {
      console.log("AI Detection Result:", result);
    })
    .catch((error) => {
      console.error("Error in AI detection:", error);
    });
  //Insert to DB
  await initDB();
   await saveResult(id, { id, screenshot: screenshotPath, transcript });
  return { screenshotPath, audioPath, transcript };
}
