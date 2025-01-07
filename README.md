# AWS EC2 Terraform module

AWS EC2 instance

#### **Usage**:

By Default this module creates an EC2 instance

Below are the mandatory fields

1. ami
2. instance_type
3. subnet_id
4. vpc_security_group_ids

Below are the mandatory tags:


| No. | Mandatory Tags|
|-----|----------------|
| 1   |BusinessFunction|
| 2   |Platform|
| 3   |Application|
| 4   |CostCenter|
| 5   |OwnerEmail|
| 6   |ContactEmail|
| 7   |Environment|
| 8   |Purpose|



Please refer this link for further understanding on EC2 terraform module : [https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/)


##### **main.tf**:

`main.tf` is a file used to create an EC2 instance by referencing the EC2 module


```
provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region     = var.region

}

locals {
  tags = {
    BusinessFunction = var.business_function
    OwnerEmail       = var.owner_email
    ContactEmail     = var.contact_email
    Platform         = var.platform
    CostCenter       = var.cost_center
    Application      = var.application
    Purpose          = var.purpose
    Environment      = var.environment

  }
}

module "ec2_instance" {
  source = "git::https://gitlab.com/syngentagroup/Terraform-Modules/terraform-aws-lambda.git?ref=latest"
  region                      = var.region                  #AWS Region
  server_type                 = var.server_type             #Server Type. For Example:infrastructure or database
  server_os                   = var.sevrer_os               #Server Os. For Example: windows or linux
  application_code            = var.application_code        #3 letter code of Application Code from CloudFactory
  server_count                = var.server_count            #Server Count. For Ex: 001,002 etc..
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids

  root_block_device = [{
                      encrypted             = true
                      iops                  = 100
                      kms_key_id            = var.kms_key_id
                      volume_size           = 30
                      volume_type           = "gp3"
                    },]

  create_additional_volume = true
  additional_volumes = [{
                    device_name           = "/dev/sdf"
                    availability_zone     = var.availability_zone
                    encrypted             = true
                    kms_key_arn           = var.kms_key_arn
                    volume_size           = 100
                    volume_type           = "gp3"
                  }]

  additional_volumes_for_attach_detach = [
    {
      device_name = "/dev/sdf"
    }
  ]

  tags = local.tags

}
```

##### **variables.tf** - Sample Example:

`variables.tf` file is used for declaring the variable values which can be used in above main.tf terraform template

```
variable "access_key" {
  description = "IAM user AccessKey"
  type        = string
  default     = "<access_key>"
}

variable "secret_key" {
  description = "IAM user SecretKay"
  type        = string
  default     = "<secret_key>"
}

variable "region" {
  description = "Region"
  type        = string
  default     = "<region>"
}
variable "server_type" {
  type = string
  description = "If you are hosting the Web Application on the Server, Server_Type value will be 'infrastructure'.If you are hosting Database on the server, Server_Type value will be 'database'"
  default="<server_type>"
}
variable "server_os" {
  type = string
  description = "If the Operating System belongs to Windows, Server_OS value will be 'windows'.If the Operating System belongs to any variant of Linux, Server_OS will be 'linux'"
  default="<server_os>"
}
variable "application_code" {
  type = string
  description = "Application code should be 3 letter code which is registered in CloudFactory"
  default="<application_code>"
}
variable "server_count" {
  type = string
  description = "Count of the Application servers. For Ex: 001,002..etc. Count will be incremented by 1 for each additional server for the application"
  default="<server_count>"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "<availability_zone>"
}

variable "subnet_id" {
  description = "SSL certificate ARN"
  type        = string
  default     = "<subnet_id>"
}

variable "ami_id" {
  description = "ami id"
  type        = string
  default     = "<ami_id>"
}

variable "security_group_ids" {
    type        = list(string)
    description = "List of Security Group Ids"
    default     = ["<security_group_id>"]
}

variable "kms_key_id" {
  description = "kms key id"
  type        = string
  default     = "<kms_key_id>"
}

variable "kms_key_arn" {
  description = "kms key arn"
  type        = string
  default     = "<kms_key_arn>"
}

variable "instance_type" {
  description = "instance type"
  type        = string
  default     = "<instance_type>"
}

variable "resource_name" {
  description = "Resource Name"
  type        = string
  default     = "<resource_name>"
}

variable "business_function" {
    type        = string
    description = "Business Function"
    default     = "<business_function>"
}
variable "platform" {
    type        = string
    description = "Platform"
    default     = "<platform>"
}
variable "cost_center" {
    type        = string
    description = "Cost Center"
    default     = "<cost_center>"
}
variable "application" {
    type        = string
    description = "Application Name"
    default     = "<application"
}
variable "owner_email" {
    type        = string
    description = "Owner Email Address"
    default     = "<owner_email>"
}
variable "contact_email" {
    type        = string
    description = "Contact Email Address"
    default     = "<contact_email>"
}
variable "environment" {
    type        = string
    description = "Environment Name"
    default     = "<environment>"
}
variable "purpose" {
    type        = string
    description = "Purpose Tag"
    default     = "<purpose>"
}

```

##### **outputs.tf** - Sample Example:

`outputs.tf` file is used to declare the parameters that you want to print once the deployment is completed

```
output "id" {
  description = "The ID of the instance"
  value       = try(module.ec2_instance.id, "")
}

output "arn" {
  description = "The ARN of the instance"
  value       = try(module.ec2_instance.arn, "")
}

output "instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = try(module.ec2_instance.instance_state, "")
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = try(module.ec2_instance.private_ip, "")
}
```

#### **Useful Commands**
1. [terraform init](https://www.terraform.io/cli/commands/init)
2. [terraform validate](https://www.terraform.io/cli/commands/validate)
3. [terraform plan](https://www.terraform.io/cli/commands/plan)
4. [terraform apply](https://www.terraform.io/cli/commands/apply)
