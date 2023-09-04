variable "application_name" {}
variable "location" {}
variable "opsmc_cidr" {
	type	=	list(string)
}
variable "opsmc_sub_cidr" {
type	=	list(string)
}
variable "vm_size" {}
variable "vm_username" {}
variable "vm_pass" {}
