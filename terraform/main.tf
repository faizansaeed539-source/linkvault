terraform {
  backend "gcs" {
    bucket = "linkvault-tfstate-project-94a7158b-ae46-4688-93c"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "project-94a7158b-ae46-4688-93c"
  region  = "us-central1"
  zone    = "us-central1-a"
}

module "network" {
  source  = "./modules/network"
  project = "project-94a7158b-ae46-4688-93c"
  region  = "us-central1"
}

module "vm" {
  source      = "./modules/vm"
  subnet_id   = module.network.subnet_id
  ssh_pub_key = file("~/.ssh/id_ed25519.pub")
}

output "vm_external_ip" {
  value = module.vm.external_ip
}
