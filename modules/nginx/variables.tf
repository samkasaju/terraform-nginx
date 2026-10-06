variable "name" {
  type = string
}

variable "external_port" {
  type = number
}

variable "image" {
  type    = string
  default = "nginx:latest"
}
