variable "results-bucket-name" {
  type = string
  default = "trivy-results-bucket"
}

variable "ssh-subnet" {
  type = string
  default = "0.0.0.0/0"
}