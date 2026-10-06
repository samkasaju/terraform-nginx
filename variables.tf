variable "sites" {
  type = map(number)

  default = {
    site-one = 8081
    site-two = 8082
  }
}
