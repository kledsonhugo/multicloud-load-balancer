module "rg" {
  source = "./modules/rg"
}

module "rede" {
  source   = "./modules/rede"
  rg_name  = module.rg.rg_name
  location = module.rg.location
}

module "compute" {
  source               = "./modules/compute"
  rg_name              = module.rg.rg_name
  location             = module.rg.location
  subnet1a_id          = module.rede.subnet1a_id
  subnet1c_id          = module.rede.subnet1c_id
  lb_domain_name_label = "lbazurekb0001"
}