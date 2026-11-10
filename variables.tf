variable "subscription_id" {
  type        = string
  description = "ID de l'abonnement Azure for Students utilisé pour le déploiement."
}

variable "location" {
  type        = string
  description = "Région Azure des ressources (celle retenue au TP Azure)."
  default     = "spaincentral"
}

variable "numero_groupe" {
  type        = number
  description = "Numéro du groupe (sert aussi d'identifiant de binôme) : noms des ressources et plan d'adressage 10.<groupe>.0.0/16."
}

variable "owner" {
  type        = string
  description = "Valeur du tag owner."
}

variable "env" {
  type        = string
  description = "Valeur du tag env."
  default     = "tp"
}

variable "vm_size" {
  type        = string
  description = "Taille des VM (celle retenue au TP Azure)."
  default     = "Standard_B2ats_v2"
}

variable "nb_vm_web" {
  type        = number
  description = "Nombre de VM web derrière le Load Balancer."
  default     = 2
}

variable "admin_username" {
  type        = string
  description = "Utilisateur administrateur des VM."
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Chemin de la clé publique SSH déposée sur les VM."
}

variable "ip_ssh_autorisee" {
  type        = string
  description = "IP publique autorisée en SSH sur la jumpbox, au format CIDR (ex : 203.0.113.10/32)."
}

variable "email_alerte" {
  type        = string
  description = "Adresse qui reçoit les alertes CPU du groupe d'actions."
}

