# MEAN Stack App — DevOps Deployment

Full-stack CRUD application built with **MongoDB, Express, Angular, Node.js**, containerized with Docker, deployed via Docker Compose on a cloud VM, with a GitHub Actions CI/CD pipeline and Nginx reverse proxy.

---

## 📁 Project Structure

```
mean-app/
├── frontend/               # Angular app
│   ├── Dockerfile
│   └── nginx.conf          # Nginx config inside frontend container
├── backend/                # Node.js + Express API
│   └── Dockerfile
├── nginx/
│   └── nginx.conf          # Reverse proxy config (routes :80 → frontend/backend)
├── .github/
│   └── workflows/
│       └── ci-cd.yml       # GitHub Actions pipeline
├── docker-compose.yml
├── .env.example
├── vm-setup.sh             # One-time VM setup script
└── README.md
```

---

## ⚙️ Local Development Setup

### Prerequisites
- Node.js 18+
- Docker & Docker Compose
- Angular CLI (`npm install -g @angular/cli`)

### Run Locally
```bash
# Clone the repo
git clone https://github.com/<your-username>/<repo-name>.git
cd mean-app

# Copy and configure environment
cp .env.example .env
# Edit .env with your values

# Start all services
docker compose up --build
```

Access the app at **http://localhost**

---

## 🐳 Docker Images

### Backend
```bash
cd backend
docker build -t <dockerhub-username>/mean-backend:latest .
docker push <dockerhub-username>/mean-backend:latest
```

### Frontend
```bash
cd frontend
docker build -t <dockerhub-username>/mean-frontend:latest .
docker push <dockerhub-username>/mean-frontend:latest
```

> Images are automatically built and pushed via the CI/CD pipeline on every push to `main`.

---

## ☁️ Cloud VM Deployment

### 1. Provision Ubuntu VM
Create an Ubuntu 22.04 VM on AWS EC2 / Azure / GCP. Open inbound port **80** in the security group/firewall.

### 2. One-Time VM Setup
```bash
# SSH into VM
ssh -i your-key.pem ubuntu@<VM_PUBLIC_IP>

# Upload and run setup script
scp vm-setup.sh ubuntu@<VM_PUBLIC_IP>:~/
chmod +x vm-setup.sh && ./vm-setup.sh

# Log out and back in for Docker group permissions
```

### 3. Deploy the App
```bash
# On the VM
mkdir -p ~/mean-app/nginx
cd ~/mean-app

# Create .env file
cat > .env <<EOF
DOCKER_USERNAME=your_dockerhub_username
MONGO_USERNAME=admin
MONGO_PASSWORD=your_secure_password
MONGO_DB=meandb
EOF

# Copy docker-compose.yml and nginx/nginx.conf to the VM, then:
docker compose pull
docker compose up -d
```

### 4. Verify Deployment
```bash
docker compose ps          # All containers should be "Up"
curl http://localhost       # Should return Angular app HTML
curl http://localhost/api/  # Should return API response
```

---

## 🔄 CI/CD Pipeline (GitHub Actions)

### Pipeline Flow
```
Push to main
    │
    ▼
Build Backend Docker Image ──► Push to Docker Hub
Build Frontend Docker Image ──► Push to Docker Hub
    │
    ▼
SSH into VM
    │
    ├── Copy latest docker-compose.yml & nginx config
    ├── docker compose pull   (pull new images)
    ├── docker compose up -d  (restart containers)
    └── docker image prune    (cleanup old images)
```

### GitHub Secrets to Configure
Go to your repo → **Settings → Secrets and variables → Actions** and add:

| Secret Name       | Description                            |
|-------------------|----------------------------------------|
| `DOCKER_USERNAME` | Your Docker Hub username               |
| `DOCKER_PASSWORD` | Your Docker Hub password or access token |
| `VM_HOST`         | Public IP of your cloud VM             |
| `VM_USER`         | SSH username (e.g., `ubuntu`)          |
| `VM_SSH_KEY`      | Private SSH key contents (PEM format)  |
| `MONGO_USERNAME`  | MongoDB admin username                 |
| `MONGO_PASSWORD`  | MongoDB admin password                 |
| `MONGO_DB`        | MongoDB database name                  |

### Viewing Pipeline Runs
Go to your repo → **Actions** tab to see live pipeline logs.

---

## 🌐 Nginx Reverse Proxy

Nginx runs as a container on port **80** and routes traffic:

| Path       | Routes To           |
|------------|---------------------|
| `/`        | Angular frontend    |
| `/api/`    | Node.js backend     |

Config file: `nginx/nginx.conf`

```nginx
# All traffic on port 80
server {
    listen 80;

    location / {
        proxy_pass http://frontend:80;   # Angular container
    }

    location /api/ {
        proxy_pass http://backend:3000;  # Express container
    }
}
```

---

## 🗄️ Database

MongoDB runs as a Docker container (`mongo:6.0`) with:
- Persistent data volume (`mongo_data`) — data survives container restarts
- Health check before backend starts
- Credentials set via environment variables

---

## 📸 Screenshots

> *(Add your screenshots here after deployment)*

- [ ] GitHub Actions pipeline running
- [ ] Docker Hub showing pushed images
- [ ] `docker compose ps` showing all containers running
- [ ] Application UI in browser
- [ ] Nginx serving on port 80

---

## 🔧 Useful Commands

```bash
# View running containers
docker compose ps

# View logs
docker compose logs -f

# Restart a single service
docker compose restart backend

# Stop everything
docker compose down

# Stop but keep volumes (preserve DB data)
docker compose stop
```

---

## 🧰 Tech Stack

| Layer       | Technology              |
|-------------|-------------------------|
| Frontend    | Angular + Nginx         |
| Backend     | Node.js + Express       |
| Database    | MongoDB 6.0             |
| Proxy       | Nginx (reverse proxy)   |
| Container   | Docker + Docker Compose |
| CI/CD       | GitHub Actions          |
| Cloud       | AWS EC2 / Azure VM      |
