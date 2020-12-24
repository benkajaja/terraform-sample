terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {

  credentials = file("cred.json")

  project = "cathay-anthos-ut"
  region  = "asia-east1"
  zone    = "asia-east1-a"
}

resource "google_compute_firewall" "fw" {
  name    = "flask-app-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
}

resource "google_compute_address" "static-ip" {
  name = "flask-app-static-ip"
}

resource "google_compute_instance" "vm_instance" {
  name         = "flask-app-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
      nat_ip = google_compute_address.static-ip.address
    }
  }
  metadata_startup_script = file("./start.sh")
  metadata = {
    sshKeys = "jaja:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}