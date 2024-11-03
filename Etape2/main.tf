terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# Création du réseau Docker pour permettre la communication entre les conteneurs
resource "docker_network" "app_network" {
  name = "app_network"
}

# Conteneur HTTP (Nginx)
resource "docker_container" "http" {
  name  = "http"
  image = docker_image.nginx.image_id

  depends_on = [docker_container.script]

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    host_path      = "${path.cwd}/app"
    container_path = "/app"
  }

  # Configuration Nginx pour rediriger les requêtes PHP
  provisioner "local-exec" {
    command = <<-EOT
      docker exec http sh -c 'echo "
      server {
        listen 80;
        server_name localhost;

        root /app;
        index index.php index.html index.htm;

        location / {
          try_files \$uri \$uri/ =404;
        }

        location ~ \\.php$ {
          root /app;
          fastcgi_pass script:9000;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
          include fastcgi_params;
        }
      }" > /etc/nginx/conf.d/default.conf && nginx -s reload'
    EOT
  }
}

# Conteneur SCRIPT (PHP-FPM)
resource "docker_container" "script" {
  name  = "script"
  image = docker_image.php.image_id

  networks_advanced {
    name    = docker_network.app_network.name
    aliases = ["script"]
  }

  volumes {
    host_path      = "${path.cwd}/app"
    container_path = "/app"
  }
}

# Conteneur DATA (MariaDB)
resource "docker_container" "data" {
  name  = "data"
  image = docker_image.mariadb.image_id

  # Configuration de l'environnement pour MariaDB
  env = [
    "MYSQL_ROOT_PASSWORD=rootpassword",
    "MYSQL_DATABASE=testdb",
    "MYSQL_USER=user",
    "MYSQL_PASSWORD=userpassword"
  ]

  networks_advanced {
    name = docker_network.app_network.name
  }

  # Expose port 3306 for SQL access (optional, can be limited to the Docker network)
  ports {
    internal = 3306
    external = 3306
  }
}

# Téléchargement de l'image Nginx
resource "docker_image" "nginx" {
  name = "nginx:1.27"
}

# Utilisation d'un Dockerfile personnalisé pour PHP avec PDO MySQL
resource "docker_image" "php" {
  name = "php_custom:8.3-fpm"
  build {
    context    = "${path.cwd}"
    dockerfile = "Dockerfile"
  }
}

# Téléchargement de l'image MariaDB
resource "docker_image" "mariadb" {
  name = "mariadb:latest"
}
