import express from 'express';
import bodyParser from "body-parser";
import { analyzeVideo } from './analyze.js';
import { getResult } from './db.js';


const app = express();
app.use(bodyParser.json());

const PORT = process.env.PORT || 8080;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
    console.log(`Server is running on ${HOST}:${PORT}`);
});

//Post
app.use("/analyze", async (req, res) => {
    const {url} = req.body;
    if (!url) {
        return res.status(400).json({ error: "URL is required" });
    }
    
    try {
         const id = await analyzeVideo(url);
        res.status(200).json(id);
    } catch (error) {
        console.error("Error analyzing video:", error);
        res.status(500).json({ error: "Failed to analyze video" });
    }
});

// Health check endpoint
app.get("/health", (req, res) => {
    res.status(200).json({ 
        status: "OK", 
        timestamp: new Date().toISOString(),
        service: "Mini Video Analysis Service"
    });
});

// GET /result/:id
app.get("/result/:id", async (req, res) => {
  const result = await getResult(req.params.id);
  if (!result) return res.status(404).json({ error: "Not found" });
  res.json(result);
});