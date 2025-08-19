# Google Cloud Engine Deployment Guide

## 🌐 Quick Deployment Steps

### 1. Create GCE Instance
```bash
# Create a small VM instance
gcloud compute instances create mini-service-vm \
  --zone=us-central1-a \
  --machine-type=e2-small \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=mini-service
```

### 2. Configure Firewall Rule
```bash
# Allow traffic on port 8080
gcloud compute firewall-rules create allow-mini-service \
  --allow tcp:8080 \
  --source-ranges 0.0.0.0/0 \
  --target-tags mini-service \
  --description "Allow Mini Service on port 8080"
```

### 3. SSH into VM and Deploy
```bash
# SSH into the VM
gcloud compute ssh mini-service-vm --zone=us-central1-a

# Run deployment script
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/Mini_Service/main/deploy-gce.sh | bash
```

### 4. Verify Deployment
```bash
# Get external IP
EXTERNAL_IP=$(gcloud compute instances describe mini-service-vm \
  --zone=us-central1-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Test the service
curl http://$EXTERNAL_IP:8080/health
```

## 🔧 SSH Port Forward Fallback

If direct access doesn't work, use SSH port forwarding:

```bash
# Forward local port 8080 to VM port 8080
gcloud compute ssh mini-service-vm \
  --zone=us-central1-a \
  --ssh-flag="-L 8080:localhost:8080"
```

Then access the service at `http://localhost:8080`

## 🛠️ Manual Setup (Alternative)

### On the VM:
```bash
# Update system
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone and run
git clone https://github.com/YOUR_USERNAME/Mini_Service.git
cd Mini_Service
docker-compose up --build -d
```

## 📊 Monitoring

### Check service status:
```bash
docker-compose ps
docker-compose logs -f
```

### View resource usage:
```bash
docker stats
htop
```

## 🔒 Security Considerations

1. **Firewall**: Only port 8080 is exposed
2. **Updates**: Regular system updates recommended
3. **Monitoring**: Set up log monitoring
4. **Backup**: Regular backup of analysis results

## 💰 Cost Optimization

- **VM Size**: e2-small is sufficient for testing
- **Preemptible**: Use preemptible instances for cost savings
- **Auto-shutdown**: Configure automatic shutdown during off-hours

```bash
# Create preemptible instance (cheaper)
gcloud compute instances create mini-service-vm \
  --zone=us-central1-a \
  --machine-type=e2-small \
  --preemptible \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud
```
