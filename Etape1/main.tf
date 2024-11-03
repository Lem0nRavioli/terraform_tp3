terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}
# provider "docker" {
#   host = "unix:///Users/username/.docker/run/docker.sock"
# }

resource "docker_network" "my_network" {
  name = "my_network"
}

resource "docker_container" "php" {
  image = docker_image.php.image_id
  name  = "php-fpm"
  networks_advanced {
    name = docker_network.my_network.name
  }
  volumes {
    host_path      = "${path.cwd}/index.php"
    container_path = "/var/www/html/index.php"
    read_only      = true
  }
}

resource "docker_container" "nginx" {
  depends_on = [docker_container.php]
  image      = docker_image.nginx.image_id
  name       = "nginx"
  networks_advanced {
    name = docker_network.my_network.name
  }
  ports {
    internal = 80
    external = 8080
  }
  volumes {
    host_path      = "${path.cwd}/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }
  volumes {
    host_path      = "${path.cwd}/index.php"
    container_path = "/var/www/html/index.php"
    read_only      = true
  }
}

resource "docker_image" "nginx" {
  name = "nginx:1.27"
}

resource "docker_image" "php" {
  name = "php:8.3-fpm"
}
