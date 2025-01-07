provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

locals {
  tags = {
    Name             = var.resource_name
    BusinessFunction = var.business_function
    OwnerEmail       = var.owner_email
    ContactEmail     = var.contact_email
    Platform         = var.platform
    CostCenter       = var.cost_center
    Application      = var.application
    Purpose          = var.purpose
    Environment      = var.environment
    CreatedByEmail   = var.created_by_email
  }

}

module "ec2_instance" {
  source = "../"
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  server_count                = "001"
  server_type                 = "infrastructure"
  server_os                   = "windows"
  application_code            = "CET"
  region                      = var.region

  root_block_device = [{
                      encrypted             = true
                      kms_key_id            = var.kms_key_id
                      volume_size           = 100
                      volume_type           = "gp3"
                    },]

  # Only for additional volumes
  create_additional_volume = true
  additional_volumes = [{
                    device_name           = "/dev/sdf"
                    availability_zone     = var.availability_zone
                    encrypted             = true
                    kms_key_arn           = var.kms_key_arn
                    volume_size           = 100
                    volume_type           = "gp3"
                  }]

  tags = local.tags


}
