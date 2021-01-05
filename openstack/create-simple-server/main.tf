terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.34.1"
    }
  }
}

variable "username" {}
variable "tenantname" {}
variable "password" {}
variable "authurl" {}
variable "region" {}
variable "imageID" {}
variable "pubkey" {}
variable "publicNetworkID" {}

provider "openstack" {
  user_name   = var.username
  tenant_name = var.tenantname
  password    = var.password
  auth_url    = var.authurl
  region      = var.region
}

resource "openstack_compute_instance_v2" "myvm" {
  name            = "terraform_vm"
  image_id        = openstack_images_image_v2.myimage.id
  # image_id        = var.imageID
  flavor_name     = "m1.small"
  key_pair        = openstack_compute_keypair_v2.mykeypair.name
  security_groups = [openstack_networking_secgroup_v2.mysecgroup.name]
  user_data       = file("./start.sh")

  network {
    name = openstack_networking_network_v2.mynetwork.name
  }
}

resource "openstack_networking_network_v2" "mynetwork" {
  name           = "terraform_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "mysubnet" {
  name       = "terraform_subnet"
  network_id = openstack_networking_network_v2.mynetwork.id
  cidr       = "192.168.100.0/24"
  gateway_ip = "192.168.100.254"
  dns_nameservers = [ "8.8.8.8" ]
  ip_version = 4
}

resource "openstack_networking_router_v2" "myrouter" {
  name                = "terraform_router"
  admin_state_up      = true
  external_network_id = var.publicNetworkID
}

resource "openstack_networking_router_interface_v2" "myrouterinterface" {
  router_id = openstack_networking_router_v2.myrouter.id
  subnet_id = openstack_networking_subnet_v2.mysubnet.id
}

resource "openstack_images_image_v2" "myimage" {
  name             = "terraform_image"
  image_source_url = "https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "shared"
}

resource "openstack_compute_keypair_v2" "mykeypair" {
  name       = "terraform_keypair"
  public_key = var.pubkey
}

resource "openstack_networking_floatingip_v2" "myip" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "myipassociate" {
  floating_ip = openstack_networking_floatingip_v2.myip.address
  instance_id = openstack_compute_instance_v2.myvm.id
}

resource "openstack_networking_secgroup_v2" "mysecgroup" {
  name        = "terraform_secgroup"
  description = "My neutron security group"
}


## Openstack will create default egress rule below
# resource "openstack_networking_secgroup_rule_v2" "rule1" {
#   direction         = "egress"
#   ethertype         = "IPv4"
#   security_group_id = openstack_networking_secgroup_v2.mysecgroup.id
# }

# resource "openstack_networking_secgroup_rule_v2" "rule2" {
#   direction         = "egress"
#   ethertype         = "IPv6"
#   security_group_id = openstack_networking_secgroup_v2.mysecgroup.id
# }

resource "openstack_networking_secgroup_rule_v2" "rule3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.mysecgroup.id
}
resource "openstack_networking_secgroup_rule_v2" "rule4" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.mysecgroup.id
}