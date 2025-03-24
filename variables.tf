# variables
variable "instance_types" {
  default = {
    "control-plane"  = "t3a.medium"
    "node-1" = "t3a.medium"
    "node-2" = "t3a.medium"
  }
}