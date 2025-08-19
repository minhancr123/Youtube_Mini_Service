import fs from "fs";
import path from "path";
import dotenv from "dotenv";
import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";

dotenv.config();

const client = new ElevenLabsClient({
  apiKey: process.env.ELEVENLABS_API_KEY,
});

function formatTime(seconds) {
  const h = String(Math.floor(seconds / 3600)).padStart(2, "0");
  const m = String(Math.floor((seconds % 3600) / 60)).padStart(2, "0");
  const s = String(Math.floor(seconds % 60)).padStart(2, "0");
  const ms = String(Math.floor((seconds % 1) * 1000)).padStart(3, "0");
  return `${h}:${m}:${s},${ms}`;
}

function saveAsSrt(transcript, outputPath) {
  let srt = "";
  transcript.words.forEach((word, idx) => {
    if (!word.start || !word.end) return;
    srt += `${idx + 1}\n${formatTime(word.start)} --> ${formatTime(word.end)}\n${word.text}\n\n`;
  });
  fs.writeFileSync(outputPath, srt, "utf-8");
  console.log(`📄 Subtitle saved: ${outputPath}`);
}

export async function transcribe(audioPath) {
  try {
    if (!fs.existsSync(audioPath)) {
      throw new Error(`Audio file not found: ${audioPath}`);
    }

    const stats = fs.statSync(audioPath);
    console.log(`🎵 Audio file size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);

    if (stats.size > 25 * 1024 * 1024) {
      throw new Error("Audio file too large. ElevenLabs limit is 25MB");
    }

    console.log("🚀 Sending transcription request...");
    const audioBlob = new Blob([await fs.promises.readFile(audioPath)], { type: "audio/wav" });

    const response = await client.speechToText.convert({
      file: audioBlob,
      modelId: "scribe_v1",
      tagAudioEvents: true,
      diarize: true,
    });

    console.log("✅ Transcription successful");

    // lưu SRT
    const srtPath = path.join("subtitles", path.basename(audioPath, path.extname(audioPath)) + ".srt");
    if (!fs.existsSync("subtitles")) fs.mkdirSync("subtitles");
    saveAsSrt(response, srtPath);

    return response;
  } catch (error) {
    console.error("❌ Transcription error:", error.message);
    if (error.response) {
      console.error("Status:", error.response.status);
      console.error("Response data:", error.response.data);
    }
    throw error;
  }
}
