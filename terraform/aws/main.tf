module "rede" {
  source = "./modules/rede"
}

module "compute" {
  source         = "./modules/compute"
  vpc_id         = module.rede.vpc_id
  subnet1a_id    = module.rede.subnet1a_id
  subnet1c_id    = module.rede.subnet1c_id
  vpc_cidr_block = module.rede.vpc_cidr_block
  elb_name       = "lbazurekb0001"
}