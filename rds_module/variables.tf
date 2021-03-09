variable "alloc_storage" {
  default     = "20"
  description = "The allocated storage in gibibytes"
}
variable "db_stor_type" {
  default     = "gp2"
  description = "One of: standard, gp2, or io1"
}
variable "db_engine" {
  default     = "mysql"
  description = "Engine type of db"
}
variable "engine_ver" {
  default     = "5.7"
  description = "Version of db engine"
}
variable "db_instance" {
  default     = "db.t2.micro"
  description = "Type of db_instance in format: db.*.*; default db.t2.micro"
}
variable "db_name" {
  description = "Name of the initial db"
}
variable "db_port" {
  default     = "3306"
  description = "Db access port"
}
variable "db_user" {
  description = "Database user"
}
variable "db_password" {
  description = "Initial database password"
}
variable "vpc_id" {
  description = "Name of VPC for RDS"
}
variable "access_ip" {
  default = "List of IP addresses for db access"
}
variable "subnet_ids" {
  description = "Subnet IDs for RDS"
}
