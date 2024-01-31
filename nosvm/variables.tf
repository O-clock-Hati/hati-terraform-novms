variable "users" {
  type = map(object({
    username   = string
    public_key = string
    hostname   = string
  }))
  # default = {...} # Ajoute les valeurs par défaut si nécessaire
}

# variable "users" {
#   type = list(object({
#     username   = string
#     public_key = string
#     hostname   = string
#   }))
#   # default = [...] # Tu peux ajouter une valeur par défaut si nécessaire
# }
