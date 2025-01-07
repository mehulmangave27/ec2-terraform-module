variable "access_key" {
  description = "IAM user AccessKey"
  type        = string
  default     = ""
}

variable "secret_key" {
  description = "IAM user SecretKay"
  type        = string
  default     = ""
}

variable "region" {
  description = "Region"
  type        = string
  default     = "eu-central-1"
}

variable "subnet_id" {  
  description = "SSL certificate ARN"
  type        = string
  default     = "subnet-0359b5b68fadafdf3"
}

variable "ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-0e162ac5086aecec2"
}

variable "security_group_ids" {
    type        = list(string)
    description = "List of Security Group Ids"
    default     = ["sg-01504f5731c88e824"]
}

variable "kms_key_id" {
  description = "kms key id"
  type        = string
  default     = "239639c7-bf7b-479f-b9b7-78c1a9b6bda0"
}

variable "kms_key_arn" {
  description = "kms key id"
  type        = string
  default     = "arn:aws:kms:eu-central-1:887968118773:key/239639c7-bf7b-479f-b9b7-78c1a9b6bda0"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "eu-central-1a"
}

variable "instance_type" {
  description = "instance type"
  type        = string
  default     = "t2.nano"
}

variable "resource_name" {
  description = "Resource Name"
  type        = string
  default     = "syn-aws-tf-example"
}

#customer-mc-ec2-instance-profile
variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = "customer-mc-ec2-instance-profile"
}


variable "business_function" {
    type        = string
    description = "Business Function"
    default     = "Infrastructure"
}
variable "platform" {
    type        = string
    description = "Platform"
    default     = "Cloud Engineering"
}
variable "cost_center" {
    type        = string
    description = "Cost Center"
    default     = "SBS42102"
}
variable "application" {
    type        = string
    description = "Application Name"
    default     = "Terraform"
}
variable "owner_email" {
    type        = string
    description = "Owner Email Address"
    default     = "srikanth.ganesan@syngenta.com"
}
variable "contact_email" {
    type        = string
    description = "Contact Email Address"
    default     = "karthik.s@syngenta.com"
}
variable "environment" {
    type        = string
    description = "Environment Name"
    default     = "Stage"
}

variable "purpose" {
    type        = string
    description = "Purpose Tag"
    default     = "Demo code"
}

variable "created_by_email" {
    type        = string
    description = "Resource created by"
    default     = "karthik.s@syngenta.com"
}

variable "backup_enabled" {
    type        = string
    description = "Enable Backup for EC2"
    default     = true
}

variable "backup_setup" {
    type        = string
    description = "Backup Configuration for workloads"
    default     = "syngenta_aws_ec2_malz_pr_950b07e9-6647-456e-bd0c-39410766aa2f"
} 

variable "backup_policy" {
    type        = string
    description = "Backup Policy for workloads"
    default     = "syngenta_rpo24_ret14d_re_5ac63037-6f0e-404b-96f9-6a1e311499a8"
}

variable "autopatcher_enabled" {
    type        = string
    description = "Enable Autopatcher"
    default     = true
}

variable "autopatcher_plan" {
    type        = string
    description = "Autopatcher tag depends based on Region and OS type"
    default     = "aws-malz-nonprod-eu-central-1-linux"
}

variable "patch_group" {
    type        = string
    description = "Patch group depends on OS and Environment"
    default     = "AWS-LIN-NPROD"
}
