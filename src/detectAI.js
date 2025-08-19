import axios from "axios";
import dotenv from "dotenv";
dotenv.config();
export async function detectAI(text){
    try {
        const response = await axios.post(
            'https://api.sapling.ai/api/v1/aidetect',
            {
                key: process.env.Sapling_Private_key,
                text,
            },
        );
        const {status, data} = response;
        console.log({status});
        console.log(JSON.stringify(data, null, 4));
    } catch (error) {
        console.error("Error detecting AI content:", error);
          const { msg } = error.response.data;
        console.log({err: msg});
    }
}