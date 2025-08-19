# Docker Setup for Mini Service

## Yêu cầu
- Docker
- Docker Compose

## Cách chạy với Docker

### 1. Build và chạy với docker-compose (Khuyến nghị)
```bash
docker-compose up --build
```

### 2. Build và chạy với Docker commands
```bash
# Build image
docker build -t mini-service .

# Run container
docker run -p 3000:3000 -v $(pwd)/audio:/app/audio -v $(pwd)/screenshots:/app/screenshots -v $(pwd)/subtitles:/app/subtitles -v $(pwd)/results.db:/app/results.db mini-service
```

### 3. Chạy ở background
```bash
docker-compose up -d
```

### 4. Xem logs
```bash
docker-compose logs -f
```

### 5. Dừng service
```bash
docker-compose down
```

## API Endpoints

Sau khi container chạy, bạn có thể truy cập:

- `POST http://localhost:3000/analyze` - Phân tích video
- `GET http://localhost:3000/result/:id` - Lấy kết quả phân tích

## Lưu ý
- Các file audio, screenshots, subtitles và database sẽ được lưu trữ persistent thông qua volumes
- Container sử dụng Google Chrome để chạy Puppeteer
- FFmpeg được cài đặt sẵn cho việc xử lý audio/video
