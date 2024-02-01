variable "users" {
  type    = list(object({
    user    = string
    public_key  = string
    cidr = string
  }))
}
