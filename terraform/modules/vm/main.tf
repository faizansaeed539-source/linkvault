variable "subnet_id" {}
variable "ssh_pub_key" {}

resource "google_compute_instance" "vm" {
  name         = "linkvault-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  metadata = {
    ssh-keys = "vaultstudiohub:${var.ssh_pub_key}"
  }

  tags = ["linkvault"]
}

output "external_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
