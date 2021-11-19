# archlinux wireguard packer template for Hetzner Cloud

This repo is used to build archlinux wireguard images (as snapshots) for use with [Hetzner Cloud](https://www.hetzner.de/cloud) by means of HashiCorp's [Packer](https://packer.io/).

## Building Images using this Repo

Please ensure that you have done the following:

  - installed `packer` on your development machine
  - set the `hcloud_token` and `ssh_keys` using a `<filename>.auto.pkrvars.hcl` file

### Internals

The resulting images are intended to support a Terraform-based (or custom) workflow that feels close to the one of native Hetzner VMs.

In particular, support for the following features available on standard Hetzner VMs is desired:

  - dynamic hostname
  - dynamic root ssh keys
  - free-form cloud-init userdata
  - full IPv6/IPv4 support
  - Hetzner Cloud Networks
  - Hetzner Cloud Volumes

## Contributing

While the repositories are mirrored on Github and Gitlab, all work happens on Sourcehut.

## License

You can redistribute and/or modify these files unter the terms of the
GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any
later version. See the LICENSE file for details.
