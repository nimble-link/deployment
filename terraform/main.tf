provider "google" {
    project = var.google_project_id
    region = var.region
    zone = var.az
}

resource "google_compute_instance" "k3s_master_instance" {
    name = "k3s-master"
    machine_type = "n1-standard-1"
    tags = ["k3s", "k3s-master", "http-server", "https-server"]

    boot_disk {
        initialize_params {
            image = "debian-9-stretch-v20200805"
        }
    }

    network_interface {
        network = "default"

        access_config {}
    }

    provisioner "local-exec" {
        command = <<EOT
            k3sup install \
            --ip ${google_compute_instance.k3s_master_instance.network_interface[0].access_config[0].nat_ip} \
            --context k3s \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami) \
            --k3s-extra-args '--no-traefik'
        EOT
    }

    depends_on = [
        google_compute_firewall.k3s-firewall,
    ]
}

resource "google_compute_instance" "k3s_worker_instance" {
    count = var.worker_nums
    name = "k3s-worker-${count.index}"
    machine_type = "n1-standard-1"
    tags = ["k3s"]

    boot_disk {
        initialize_params {
            image = "debian-9-stretch-v20200805"
        }
    }

    network_interface {
        network = "default"

        access_config {}
    }

    provisioner "local-exec" {
        command = <<EOT
            k3sup join \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --server-ip ${google_compute_instance.k3s_master_instance.network_interface[0].access_config[0].nat_ip} \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami)
        EOT
    }

    depends_on = [
        google_compute_firewall.k3s-firewall,
    ]
}

resource "google_compute_firewall" "k3s-firewall" {
    name = "k3s-firewall"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["6443"]
    }

    target_tags = ["k3s"]
}
