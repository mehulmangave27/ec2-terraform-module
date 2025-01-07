variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}
variable "region" {
  type        = string
  description = "Region"
  validation {
    condition     = contains(["us-east-1", "eu-central-1"], lower(var.region)) ? true : false
    error_message = "Variable Region value should be either us-east-1 or eu-central-1."
  }

}
variable "server_type" {
  type        = string
  description = "If you are hosting the Web Application on the Server, Server_Type value will be 'infrastructure'.If you are hosting Database on the server, Server_Type value will be 'database'"
  validation {
    condition     = contains(["infrastructure", "database"], lower(var.server_type)) ? true : false
    error_message = "Variable Server Type value should be either infrastructure or database only."
  }
}
variable "server_os" {
  type        = string
  description = "If the Operating System belongs to Windows, Server_OS value will be 'windows'.If the Operating System belongs to any variant of Linux, Server_OS will be 'linux'"
  validation {
    condition     = contains(["windows", "linux"], lower(var.server_os)) ? true : false
    error_message = "Variable Server OS value should be either windows or linux only."
  }
}
variable "application_code" {
  type        = string
  description = "Application code should be 3 letter code which is registered in CloudFactory"
  validation {
    condition     = length(var.application_code) == 3 ? true : false
    error_message = "Variable Application Code should a 3 letter word from CloudFactory"
  }
}
variable "server_count" {
  type        = string
  description = "Count of the Application servers. For Ex: 001,002..etc. Count will be incremented by 1 for each additional server for the application"
  validation {
    condition     = length(var.server_count) == 3 ? true : false
    error_message = "Variable Server Count should be a 3 letter Count.For Ex:001,002..etc. "
  }
}
variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = false

  validation {
    condition     = (length(regexall("^false$", var.associate_public_ip_address)) > 0)
    error_message = "Cannot associate Public IP address with an instance in a VPC! Please set the flag to false"
  }

}

variable "availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = true
}

variable "create_additional_volume" {
  description = "If true, addtional volumes will be created"
  type        = bool
  default     = false
}

variable "additional_volumes" {
  description = "Additional volumes to attach to the instance"
  type        = list(map(string))
  default     = []

  validation {
    condition = alltrue([
      for r in var.additional_volumes : can(r.encrypted) ? (length(regexall("^true$", r.encrypted)) > 0) : false
    ])
    error_message = "Additional volume must be encrypted! Please set the flag to true!"
  }

  validation {
    condition = alltrue([
      for r in var.additional_volumes : can(length(r.volume_type)) ? contains(["gp3"], r.volume_type) : false
    ])
    error_message = "Additional volume's volume type must be set to gp3!"
  }

}

variable "additional_volumes_for_attach_detach" {
  description = "Additional volumes to attach to the instance"
  type        = list(map(string))
  #default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = false
}

variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it."
  type        = bool
  default     = null
}

#customer-mc-ec2-instance-profile
variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = "customer-mc-ec2-instance-profile"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
  default     = null
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(any)
  default     = []
  validation {
    condition = alltrue([
      for r in var.root_block_device : can(r.encrypted) ? contains([true], r.encrypted) : false
    ])
    error_message = "Root block device must be encrypted! Please set the flag to true!"
  }

  validation {
    condition = alltrue([
      for r in var.root_block_device : can(length(r.volume_type)) ? contains(["gp3"], r.volume_type) : false
    ])
    error_message = "Root block device's volume type must be set to gp3!"
  }

}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
}

variable "tags" {
  description = "A map of mandatory tags to add to all resources"
  type        = map(string)


  validation {
    condition     = can(length(var.tags["BusinessFunction"])) ? length(var.tags["BusinessFunction"]) >= 2 : false
    error_message = "BusinessFunction tag is required, It can't be null or Empty and minimum length should be 2!"
  }

  validation {
    condition     = can(length(var.tags["OwnerEmail"])) ? (length(var.tags["OwnerEmail"]) >= 2) && (length(regexall("^[\\w-._]+@syngenta.+[a-z]{2,4}$", var.tags["OwnerEmail"])) > 0) : false //&& can(length(var.tags["OwnerEmail"] >= 2)) //&& can(regex("^[a-z0-9]+@syngenta.+[a-z]{2,4}$", var.tags["OwnerEmail"]))
    error_message = "OwnerEmail tag is required, It can't be null or Empty and should be syngenta mail id"
  }

  validation {
    condition     = can(length(var.tags["ContactEmail"])) ? (length(var.tags["ContactEmail"]) >= 2) && (length(regexall("^[\\w-._]+@syngenta.+[a-z]{2,4}$", var.tags["ContactEmail"])) > 0) : false //&& can(length(var.tags["OwnerEmail"] >= 2)) //&& can(regex("^[a-z0-9]+@syngenta.+[a-z]{2,4}$", var.tags["OwnerEmail"]))
    error_message = "ContactEmail tag is required, It can't be null or Empty and should be syngenta mail id"
  }

  validation {
    condition     = can(length(var.tags["Application"])) ? length(var.tags["Application"]) >= 2 : false
    error_message = "Application tag is required, It can't be null or Empty!"
  }

  validation {
    condition     = can(length(var.tags["Environment"])) ? length(var.tags["Environment"]) >= 2 && (length(regexall("^(Development|Test|Stage|Production)$", var.tags["Environment"])) > 0) : false
    error_message = "Environment tag is required, It can't be null or Empty! Correct values are Development or Test or Stage or Production"
  }

  validation {
    condition     = can(length(var.tags["Platform"])) ? length(var.tags["Platform"]) >= 2 : false
    error_message = "Platform tag is required, It can't be null or Empty!"
  }

  validation {
    condition     = can(length(var.tags["CostCenter"])) ? length(var.tags["CostCenter"]) >= 2 : false
    error_message = "CostCenter tag is required, It can't be null or Empty!"
  }

  validation {
    condition     = can(length(var.tags["CreatedByEmail"])) ? (length(var.tags["CreatedByEmail"]) >= 2) && (length(regexall("^[\\w-._]+@syngenta.+[a-z]{2,4}$", var.tags["CreatedByEmail"])) > 0) : false //&& can(length(var.tags["OwnerEmail"] >= 2)) //&& can(regex("^[a-z0-9]+@syngenta.+[a-z]{2,4}$", var.tags["OwnerEmail"]))
    error_message = "CreatedByEmail tag is required, It can't be null or Empty and should be syngenta mail id"
  }

}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
}

variable "iac_framework" {
  description = "IaC Framework Type"
  type        = string
  default     = "Terraform"
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = map(string)
  default = {
    "http_endpoint"               = "enabled"
    "http_put_response_hop_limit" = 1
    "http_tokens"                 = "optional"
  }
}
