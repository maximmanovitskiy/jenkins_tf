module "rds" {
  source        = "../rds_module"
  vpc_id        = module.vpc.id
  subnet_ids    = module.subnets.id
  alloc_storage = var.alloc_storage
  db_stor_type  = var.db_stor_type
  db_engine     = var.db_engine
  engine_ver    = var.engine_ver
  db_instance   = var.db_instance
  db_name       = var.db_name
  db_port       = var.db_port
  db_user       = var.db_user
  db_password   = var.db_passwd
  access_ip     = var.access_ip

  depends_on = [module.vpc, module.subnets]
}
module "vpc" {
  source         = "../vpc_module"
  vpc_cidr_block = "10.25.0.0/16"
}
module "subnets" {
  source             = "../subnet_module"
  vpc_id             = module.vpc.id
  subnet_cidr_block  = ["10.25.0.0/24", "10.25.5.0/24"]
  map_public_ip      = false
  availability_zones = data.aws_availability_zones.available.names
}
