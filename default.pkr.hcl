variable "hcloud_token" {
  type = string
}

variable "ssh_keys" {
  type = list(string)
}

locals {
  snapshotbuildtime = formatdate("YYYY-MM-DD-hhmm", timestamp())
  # Also here I believe naming this variable `buildtime` could lead to 
  # confusion mainly because this is evaluated a 'parsing-time'.
  hcloud-servertype = "cx11"
  arch-release = "{{ isotime `2006-01` }}-01"
  system-keymap = "us"
  system-locale = "en_US.UTF-8"
  system-timezone = "UTC"
  extra-packages = ""
  extra-services = ""
}

source "hcloud" "archlinux" {
  image        = "debian-11"
  location     = "hel1"
  server_type  = "cx11"
  ssh_username = "root"
  token        = "${var.hcloud_token}"
  rescue       = "linux64"
  ssh_keys     = "${var.ssh_keys}"
  ssh_agent_auth = true
  server_name = "archlinux-${ local.snapshotbuildtime }"
  snapshot_name = "archlinux-${ local.snapshotbuildtime }"
  snapshot_labels = {
    "packer.io/version" = "${packer.version}",
    "packer.io/build.time" = "${ local.snapshotbuildtime }",
    "os-flavor" = "archlinux",
    "archlinux/iso.release" = "${local.arch-release}",
    "image_type" = "archlinux"
  }
}

build {
  sources = ["source.hcloud.archlinux"]

  provisioner "shell" {
    script = "files/00-filesystem.sh"
  }

  provisioner "shell" {
    script = "files/10-install-bootstrap.sh"
    environment_vars = [
      "ARCH_RELEASE=${ local.arch-release}",
      "EXTRA_PACKAGES=${ local.extra-packages }",
      "KEYMAP=${ local.system-keymap }",
      "LOCALE=${ local.system-locale }",
      "TIMEZONE=${ local.system-timezone }"
    ]
  }

  provisioner "file" {
    source = "files/etc/cloud/cloud.cfg.d/90-hetznercloud.cfg"
    destination = "/mnt/etc/cloud/cloud.cfg.d/90-hetznercloud.cfg"
  }

  provisioner "file" {
    source = "files/etc/cloud/cloud.cfg.d/99-hetznercloud.cfg"
    destination = "/mnt/etc/cloud/cloud.cfg.d/99-hetznercloud.cfg"
  }

  provisioner "file" {
    source = "files/etc/systemd/network/default.network"
    destination = "/mnt/etc/systemd/network/default.network"
  }

  provisioner "file" {
    source = "files/etc/ssh/sshd_config"
    destination = "/mnt/etc/ssh/sshd_config"
  }

  provisioner "file" {
    source = "files/etc/mkinitcpio.conf"
    destination = "/mnt/etc/mkinitcpio.conf"
  }

  provisioner "shell" {
    inline = ["mkdir -p /mnt/root/.ssh"]
  }

  provisioner "shell" {
    script = "files/11-install-chroot.sh"
    environment_vars = [
      "ARCH_RELEASE=${ local.arch-release}",
      "EXTRA_SERVICES=${ local.extra-services }",
      "KEYMAP=${ local.system-keymap }",
      "LOCALE=${ local.system-locale }",
      "TIMEZONE=${ local.system-timezone }"
    ]
  }

  provisioner "shell" {
    script = "files/99-cleanup.sh"
  }
}
