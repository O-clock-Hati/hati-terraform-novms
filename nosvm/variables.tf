variable "users" {
  type = map(object({
    username   = string
    public_key = string
    hostname   = string
  }))
}