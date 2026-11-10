variable "subscription_id" {
  type        = string
  description = "ID de l'abonnement Azure for Students utilisé pour le déploiement."
}

variable "location" {
  type        = string
  description = "Région Azure du compte de stockage."
  default     = "spaincentral"
}

variable "numero_groupe" {
  type        = number
  description = "Numéro du groupe (identifiant du binôme), utilisé dans le nom des ressources."
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
