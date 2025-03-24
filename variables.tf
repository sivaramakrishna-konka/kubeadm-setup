# variables
variable "instance_types" {
  default = {
    "master"  = "t3a.small"
    "node1" = "t3a.small"
    "node2" = "t3a.small"
  }
}