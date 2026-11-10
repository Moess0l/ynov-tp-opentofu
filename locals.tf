locals {
  suffixe = "nimbus-${var.numero_groupe}"

  tags = {
    projet = "nimbusshop"
    owner  = var.owner
    env    = var.env
  }

  cidr_vnet  = "10.${var.numero_groupe}.0.0/16"
  cidr_web   = cidrsubnet(local.cidr_vnet, 8, 1)
  cidr_admin = cidrsubnet(local.cidr_vnet, 8, 2)

  vm_web = toset([for i in range(1, var.nb_vm_web + 1) : tostring(i)])

  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}
