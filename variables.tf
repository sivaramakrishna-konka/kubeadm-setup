# variables
variable "instance_types" {
  default = {
    "master"  = "t3a.medium"
    "node1" = "t3a.medium"
    "node2" = "t3a.medium"
    "node3" = "t3a.medium"
  }
}
