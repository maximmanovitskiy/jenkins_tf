variable "region" {
  description = "Region for AWS resources"
}
variable "alloc_storage" {
  description = "The allocated storage in gibibytes"
}
variable "db_stor_type" {
  description = "One of: standard, gp2, or io1"
}
variable "db_engine" {
  description = "Engine type of db"
}
variable "engine_ver" {
  description = "Version of db engine"
}
variable "db_instance" {
  description = "Type of db_instance in format: db.*.*; default db.t2.micro"
}
variable "db_name" {
  description = "Name of the initial db"
}
variable "db_port" {
  description = "Db access port"
}
variable "db_user" {
  description = "Database user"
}
variable "db_passwd" {
  description = "Password for initial database user"
}
variable "access_ip" {
  type        = list(any)
  description = "List of IP addresses allowed to access db"
}
variable "resource_owner" {
  description = "Value for the tag 'Owner'"
}
