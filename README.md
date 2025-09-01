# PHP 5.3 Docker Environment

## Project Structure
- `www/httpdocs/` - Public web directory (Apache DocumentRoot)
- `config/` - Apache and PHP configuration files
- `backup/` - Database backup files

## How to Use

### Quick Start (Development)
1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd php-5.3
   ```

2. **Start the development environment**
   ```bash
   docker compose up -d --build
   ```

3. **Wait for services to start** (about 2-3 minutes for first build)
   ```bash
   docker compose ps  # Check if all services are running
   ```

4. **Access your application**
   - Main app: http://localhost
   - PHP info: http://localhost/info.php
   - Database test: http://localhost/sql_test.php
   - phpMyAdmin: http://localhost:8080

### First-Time Setup
After starting the containers for the first time:

1. **Restore database from backup**
   ```bash
   cat backup/channelt20250718002.sql | docker exec -i mysql /usr/bin/mysql -u root --password=yWuSRG6an436 channel
   ```

2. **Verify database connection**
   - Visit http://localhost/sql_test.php
   - Should show data from the `maillist` table

### Development Workflow

#### Making Code Changes
1. **Edit files** in `www/httpdocs/` directory
2. **Changes are reflected immediately** (no restart needed)
3. **For PHP configuration changes**, restart PHP service:
   ```bash
   docker compose restart php
   ```

#### Database Operations
- **View data**: Use phpMyAdmin at http://localhost:8080
- **Create backup**:
  ```bash
  docker exec mysql /usr/bin/mysqldump -u root --password=yWuSRG6an436 channel > backup/backup-$(date +%Y%m%d).sql
  ```
- **Restore backup**:
  ```bash
  cat backup/your-backup-file.sql | docker exec -i mysql /usr/bin/mysql -u root --password=yWuSRG6an436 channel
  ```

#### Viewing Logs
- **All services**: `docker compose logs -f`
- **PHP only**: `docker compose logs -f php`
- **MySQL only**: `docker compose logs -f mysql`

### Production Deployment

#### Option 1: Google Cloud Run (Recommended)
1. **Build production image**
   ```bash
   docker build -f Dockerfile.production -t php53-prod .
   ```

2. **Test locally**
   ```bash
   docker run -p 8080:8080 -e DB_HOST=34.61.52.150 php53-prod
   ```

3. **Deploy to GCP**
   ```bash
   gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/my-php53 -f Dockerfile.production
   gcloud run deploy my-php53 --image gcr.io/YOUR_PROJECT_ID/my-php53 --platform managed --allow-unauthenticated
   ```

#### Option 2: Local Production Test
```bash
# Build and run production container
docker build -f Dockerfile.production -t php53-prod .
docker run -p 8080:8080 \
  -e DB_HOST=mysql \
  -e DB_NAME=channel \
  -e DB_USER=channel \
  -e DB_PASS=chen1qaz2wsx \
  php53-prod
```

### Common Tasks

#### Stop Everything
```bash
docker compose down
```

#### Complete Reset (⚠️ Deletes all data)
```bash
docker compose down -v
docker compose up -d --build
# Restore backup:
cat backup/channelt20250718002.sql | docker exec -i mysql /usr/bin/mysql -u root --password=yWuSRG6an436 channel
```

#### Clean Up Docker Resources
```bash
docker system prune -f
docker volume prune -f
```

#### Update Application Files
1. **Copy new files** to `www/httpdocs/`
2. **Set permissions**:
   ```bash
   sudo chown -R $USER:$USER www/httpdocs/
   chmod -R 755 www/httpdocs/
   ```
3. **Restart if needed**: `docker compose restart php`

### Project Files Overview
- `Dockerfile` - Development environment
- `Dockerfile.production` - Production-optimized build
- `docker-compose.yml` - Multi-service development setup
- `docker-compose.gcp.yml` - Optional: Test against Cloud SQL locally
- `config/apache2.conf` - Apache web server configuration
- `config/php.ini` - PHP 5.3 configuration
- `www/httpdocs/` - Your web application files
- `backup/` - Database backup files
- `build-helpers/` - Build dependencies and headers

### Docker Commands

#### Starting/Stopping Services
- `docker compose up` - Start all services (foreground)
- `docker compose up -d` - Start all services (background)
- `docker compose up -d --build` - Rebuild and start all services
- `docker compose down` - Stop and remove all containers
- `docker compose stop` - Stop all services (keep containers)
- `docker compose start` - Start stopped services
- `docker compose restart` - Restart all services

#### Individual Service Management
- `docker compose up -d php` - Start only PHP service
- `docker compose up -d mysql` - Start only MySQL service
- `docker compose restart php` - Restart only PHP service
- `docker compose logs php` - View PHP service logs
- `docker compose logs -f mysql` - Follow MySQL logs in real-time

#### Container Access
- `docker compose exec php bash` - Access PHP container shell
- `docker compose exec mysql bash` - Access MySQL container shell
- `docker compose exec phpmyadmin bash` - Access phpMyAdmin container shell

#### Debugging & Maintenance
- `docker compose ps` - Show running containers status
- `docker compose logs` - View all services logs
- `docker compose logs -f` - Follow all logs in real-time
- `docker system prune` - Clean up unused Docker resources
- `docker compose down -v` - Stop and remove containers + volumes (⚠️ deletes database data)

### Access your application
- URL: http://localhost
- Files are served from `www/httpdocs/` directory

### Available test pages
- `http://localhost/` - Main application page
- `http://localhost/info.php` - PHP information page
- `http://localhost/sql_test.php` - Database connection test

### phpMyAdmin
- URL: http://localhost:8080
- Server: `mysql`
- Database: `channel`
- Username: `channel`
- Password: `chen1qaz2wsx`

- Username: `root`
- Password: `yWuSRG6an436`

### Google Cloud SQL
- IP: `34.61.52.150`
- Internal IP: `10.76.49.4`
- Database: `channel`
- Username: `channel`
- Password: `chen1qaz2wsx`

### Edit Config SQL
```bash
file: www/httpdocs/application/config/database.php
```
- $db['default']['hostname'] = 'mysql';
- $db['default']['username'] = 'channel';
- $db['default']['password'] = 'chen1qaz2wsx';
- $db['default']['database'] = 'channel';
- $db['default']['dbdriver'] = 'mysqli';

## SQL statement example:
```bash
$servername = "mysql";
$username = "channel";
$password = "chen1qaz2wsx";

$conn = new mysqli($servername, $username, $password, "channel");
$sql = "SELECT * FROM `maillist` WHERE `id` IS NOT NULL LIMIT 10;";
$result = $conn->query($sql) or die('MySQL query error');
while($row = $result->fetch_array(MYSQLI_ASSOC)){
    $emails = $row["mail"];
    $Keynote =  $row["Keynote"];
    $Sender =  $row["Sender"];
    $content =  $row["content"];
    echo "Email: $emails, Keynote: $Keynote, Sender: $Sender, Content: $content <br>";
}
```

# Backup
### MYSQL
```bash
docker exec mysql /usr/bin/mysqldump -u root --password=yWuSRG6an436 channel > <FILE_NAME>
docker exec mysql /usr/bin/mysqldump -u root --password=yWuSRG6an436 channel > backup/channelt20250718002.sql
```

# Restore
### MYSQL
```bash
cat <FILE_NAME> | docker exec -i mysql /usr/bin/mysql -u root --password=yWuSRG6an436 channel
cat backup/channelt20250718002.sql | docker exec -i mysql /usr/bin/mysql -u root --password=yWuSRG6an436 channel
```

## I make some SQL backup in 
- `backup/channelt20250718001.sql`
- `backup/channelt20250718002.sql`

## Important Notes
- **Public Directory**: The web server serves files from `www/httpdocs/` (not `www/html/`)
- **PHP Version**: This environment uses PHP 5.3 (legacy version)
- **MySQL Version**: Uses MySQL 5.7 for compatibility
- **SSL Certificates**: GCP Cloud SQL certificates are included for production connections
- **File Permissions**: Make sure files in `www/httpdocs/` have proper permissions when adding new content

## Troubleshooting

### Common Issues
- **Port already in use**: If port 80 or 8080 is busy, stop other web servers or change ports in `docker-compose.yml`
- **Permission denied**: Run `sudo chown -R $USER:$USER www/httpdocs/` to fix file permissions
- **Database connection failed**: Make sure MySQL container is running with `docker compose ps`
- **Changes not reflected**: Restart PHP service with `docker compose restart php`

### Fresh Start
If you encounter issues, try a clean restart:
```bash
docker compose down
docker compose up -d --build
```

### Reset Database (⚠️ Deletes all data)
```bash
docker compose down -v
docker compose up -d
# Then restore from backup:
cat backup/channelt20250718002.sql | docker exec -i mysql /usr/bin/mysql -u root --password=yWuSRG6an436 channel
```

---

## Google Cloud Platform Deployment

### Prerequisites
1. Install Google Cloud SDK: `gcloud components install`
2. Authenticate: `gcloud auth login`
3. Set project: `gcloud config set project YOUR_PROJECT_ID`
4. Enable required APIs:
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   ```

### Testing Against Cloud SQL Locally (Optional)
Before deploying to GCP, you can test your application locally against Cloud SQL:

```bash
# Test your app against Cloud SQL from local machine
docker compose -f docker-compose.gcp.yml up -d

# Access your app at http://localhost:8080
# This uses the production Dockerfile with Cloud SQL connection
```

**Note**: Make sure your Cloud SQL instance allows connections from your local IP address.

### Option 1: Cloud Run (Recommended)
Cloud Run is ideal for containerized applications with automatic scaling.

#### Step 1: Build and deploy to Cloud Run
```bash
# Build and push to Container Registry using the production Dockerfile
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/my-php53 -f Dockerfile.production

# Deploy to Cloud Run
gcloud run deploy my-php53 \
    --image gcr.io/YOUR_PROJECT_ID/my-php53 \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --set-env-vars="DB_HOST=34.61.52.150,DB_NAME=channel,DB_USER=channel,DB_PASS=chen1qaz2wsx"
```

### Option 2: Compute Engine VM
For more control, deploy on a VM instance.

#### Create VM instance
```bash
gcloud compute instances create my-php53-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=http-server,https-server

# Allow HTTP traffic
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server
```

#### Deploy to VM
```bash
# SSH into the VM
gcloud compute ssh my-php53-vm --zone=us-central1-a

# On the VM, install Docker
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

# Clone your project and run
git clone YOUR_REPO_URL
cd php-5.3.3
# Update database config to use Cloud SQL IP: 34.61.52.150
sudo docker-compose up -d
```

### Option 3: Google Kubernetes Engine (GKE)
For high availability and scalability.

#### Create cluster
```bash
gcloud container clusters create my-cluster \
    --zone=us-central1-a \
    --num-nodes=2 \
    --machine-type=e2-medium
```

#### Deploy with Kubernetes
Create `k8s-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-php53
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-php53
  template:
    metadata:
      labels:
        app: my-php53
    spec:
      containers:
      - name: php
        image: gcr.io/YOUR_PROJECT_ID/my-php53
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          value: "34.61.52.150"
        - name: DB_NAME
          value: "channel"
---
apiVersion: v1
kind: Service
metadata:
  name: service
spec:
  selector:
    app: my-php53
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

Deploy:
```bash
kubectl apply -f k8s-deployment.yaml
```

### Database Configuration for GCP

#### Update database config for Cloud SQL
Edit `www/httpdocs/application/config/database.php`:
```php
$db['default']['hostname'] = '34.61.52.150';  // Cloud SQL IP
$db['default']['username'] = 'channel';
$db['default']['password'] = 'chen1qaz2wsx';
$db['default']['database'] = 'channel';
$db['default']['dbdriver'] = 'mysqli';
```

#### SSL Connection (if required)
```php
$db['default']['hostname'] = '34.61.52.150';
$db['default']['username'] = 'channel';
$db['default']['password'] = 'chen1qaz2wsx';
$db['default']['database'] = 'channel';
$db['default']['dbdriver'] = 'mysqli';
$db['default']['ssl_ca'] = '/etc/ssl/certs/gcp-cloud-sql-server-ca.pem';
$db['default']['ssl_cert'] = '/etc/ssl/certs/gcp-cloud-sql-client-cert.pem';
$db['default']['ssl_key'] = '/etc/ssl/certs/gcp-cloud-sql-client-key.pem';
```

### Cost Optimization Tips
- **Cloud Run**: Pay only when serving requests (best for low traffic)
- **Compute Engine**: Use preemptible instances for cost savings
- **Cloud SQL**: Consider smaller instances or shared-core machines
- **Container Registry**: Clean up old images regularly

### Monitoring and Logs
```bash
# View Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision"

# View Compute Engine logs
gcloud logging read "resource.type=gce_instance"

# Monitor with Cloud Monitoring (set up alerts for errors)
```# php-5.3
# php-5.3
