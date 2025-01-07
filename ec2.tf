#EC2 module is Developed by Cloud Engineering Team, please reach out in case of any questions or concerns. DLGlobalCloudEngineering@syngenta.com

#Block for Provisioning EC2 Instance, Provide NC AMIs ONLY, Use customer-mc-ec2-instance-profile for post provisioning activities
locals {
  region           = lower(var.region) == "us-east-1" ? "usae" : "deaw"
  server_type      = lower(var.server_type) == "infrastructure" ? "i" : "d"
  server_os        = lower(var.server_os) == "windows" ? "w" : "l"
  environment      = lower(var.tags["Environment"]) == "production" ? "p" : (lower(var.tags["Environment"]) == "development" ? "d" : (lower(var.tags["Environment"]) == "stage" ? "s" : "t"))
  backup_setup     = lower(var.tags["Environment"]) == "production" ? (lower(var.region) == "us-east-1" ? "syngenta_aws_ec2_malz_pr_2f7bd8fb-3822-4253-b1d4-515cccc23830" : "syngenta_aws_ec2_malz_pr_950b07e9-6647-456e-bd0c-39410766aa2f") : "syngenta_aws_ec2_malz_no_91fc308e-2c22-4dcf-bdea-f36530a92ac9"
  backup_policy    = lower(var.tags["Environment"]) == "production" ? "syngenta_rpo24_ret14d_re_5ac63037-6f0e-404b-96f9-6a1e311499a8" : "syngenta_rpo24_ret5d_1fcc3b7c-5d25-419e-8a1c-5effe5f3f936"
  autopatcher_plan = local.region == "usae" ? (local.environment == "p" ? (local.server_os == "w" ? "aws-malz-prod-us-east-1-windows" : "aws-malz-prod-us-east-1-linux") : (local.server_os == "w" ? "aws-malz-nonprod-us-east-1-windows" : "aws-malz-nonprod-us-east-1-linux")) : (local.environment == "p" ? (local.server_os == "w" ? "aws-malz-prod-eu-central-1-windows" : "aws-malz-prod-eu-central-1-linux") : (local.server_os == "w" ? "aws-malz-nonprod-eu-central-1-windows" : "aws-malz-nonprod-eu-central-1-linux"))
  patch_group      = local.environment == "p" ? (local.server_os == "w" ? "AWS-WIN-PROD" : "AWS-LIN-PROD") : (local.server_os == "w" ? "AWS-WIN-NPROD" : "AWS-LIN-NPROD")
  stack_id         = random_string.stack_id.result
}

resource "random_string" "stack_id" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "aws_instance" "instance" {

  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  associate_public_ip_address = false
  disable_api_termination     = var.disable_api_termination
  availability_zone           = var.availability_zone
  user_data                   = var.user_data
  monitoring                  = var.monitoring
  ebs_optimized               = var.ebs_optimized

  #Block for Root EBS Volume, KMS Encrypted, Type GP3 
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_arn", null)
      volume_size           = lookup(root_block_device.value, "volume_size", 100)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      delete_on_termination = try(lookup(root_block_device.value, "delete_on_termination", "false"), false)
      tags = merge(
        var.tags,
        {
          "Name" = "${local.region}${local.server_type}${local.server_os}${lower(var.application_code)}${local.environment}${var.server_count}-root"
        },
        {
          "IACFramework" = var.iac_framework
        }
      )
    }
  }

  #Block for metadata options
  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, "enabled")
      http_tokens                 = try(metadata_options.value.http_tokens, "optional")
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, 1)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }

 
  

  #Block for Tag Enforce
  tags = merge(
    {
      "IACFramework" = var.iac_framework
    },
    {
      "Name" = "${local.region}${local.server_type}${local.server_os}${lower(var.application_code)}${local.environment}${var.server_count}"
    },
    var.tags,
    {
      "BACKUP_ENABLED"      = "true",
      "BACKUP_SETUP"        = local.backup_setup,
      "BACKUP_POLICY"       = local.backup_policy,
      "Autopatcher_enabled" = "true",
      "Autopatcher_plan"    = local.autopatcher_plan
    },
    {
      "terraform-id" = "${local.region}${local.server_type}${local.server_os}${lower(var.application_code)}${local.environment}${var.server_count}-${local.stack_id}"
    }
  )
}

# For additional volumes
resource "aws_ebs_volume" "main" {
  #count = var.create_additional_volume ? length(var.additional_volumes) : 0
  for_each = {
    for index, av in var.additional_volumes : av.device_name => av
  }
  #for_each          = toset(var.additional_volumes)
  availability_zone = try(lookup(each.value, "availability_zone", null), null)
  size              = lookup(each.value, "volume_size", 100)
  encrypted         = lookup(each.value, "encrypted", true)
  kms_key_id        = lookup(each.value, "kms_key_arn", null)
  type              = lookup(each.value, "volume_type", "gp3")
  iops              = lookup(each.value, "iops", null)
  snapshot_id       = try(lookup(each.value, "snapshot_id", null), null)

  tags = merge(
    var.tags,
    {
      "Name" = "${local.region}${local.server_type}${local.server_os}${lower(var.application_code)}${local.environment}${var.server_count}-${replace(trimprefix(lower(lookup(each.value, "device_name")), "/"), "/", "-")}"
    },
    {
      "IACFramework" = var.iac_framework
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# For additional volume attachments
resource "aws_volume_attachment" "this" {
  #count       = var.create_additional_volume ? length(var.additional_volumes) : 0
  for_each = {
    for index, av in var.additional_volumes_for_attach_detach : av.device_name => av if av.device_name != "/dev/sda1"
  }
  device_name = lookup(each.value, "device_name", null)
  volume_id   = try(lookup(each.value, "volume_id", null), null) == null ? aws_ebs_volume.main[lookup(each.value, "device_name", null)].id : try(lookup(each.value, "volume_id", null), null)
  instance_id = aws_instance.instance.id
  depends_on  = [aws_ebs_volume.main]
}
