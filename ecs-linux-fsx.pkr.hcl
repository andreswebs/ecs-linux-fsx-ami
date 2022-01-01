
variable "name" {
  type    = string
  default = "ecs-linux-fsx"
}

variable "subnet_id" {
  type    = string
  default = env("SUBNET_ID")
}

variable "ami_users" {
  type    = string
  default = env("AMI_USERS")
}

variable "packer_manifest" {
  type    = string
  default = env("PACKER_MANIFEST")
}

variable "fsx_username" {
  type    = string
  default = env("FSX_USERNAME")
}

variable "fsx_password" {
  type    = string
  default = env("FSX_PASSWORD")
}

variable "fsx_domain" {
  type    = string
  default = env("FSX_DOMAIN")
}

variable "fsx_creds" {
  type    = string
  default = env("FSX_CREDS")
}

variable "fsx_ip_address" {
  type    = string
  default = env("FSX_IP_ADDRESS")
}

variable "fsx_file_share" {
  type    = string
  default = env("FSX_FILE_SHARE")
}

variable "fsx_mount_point" {
  type    = string
  default = env("FSX_MOUNT_POINT")
}

variable "fsx_cifs_max_buf_size" {
  type    = string
  default = env("FSX_CIFS_MAX_BUF_SIZE")
}

variable "fsx_users" {
  type    = string
  default = env("FSX_USERS")
}

data "amazon-ami" "amzn_ecs_optimized" {
  filters = {
    name                = "amzn-ami-*-amazon-ecs-optimized"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
}

locals {
  ami_name        = "${var.name}-${formatdate("YYYY-MMM-DD-hh-mm-ss-ZZZ", timestamp())}"
  ami_users       = split(",", var.ami_users)
  scripts         = "${path.root}/scripts"
  packer_manifest = var.packer_manifest == "" || var.packer_manifest == null ? "${path.root}/outputs/packer-manifest.json" : var.packer_manifest
}

source "amazon-ebs" "this" {

  ami_name                 = local.ami_name
  ami_users                = local.ami_users
  instance_type            = "m5a.large"
  subnet_id                = var.subnet_id
  ssh_username             = "ec2-user"
  source_ami               = data.amazon-ami.amzn_ecs_optimized.id
  user_data_file           = "${local.scripts}/userdata.sh"
  ssh_file_transfer_method = "scp"
  communicator             = "ssh"

  run_tags = {
    Name = "packer-ami-creation-ec2"
  }

  run_volume_tags = {
    Name = "packer-ami-creation-ebs"
  }

  tags = {
    Name = local.ami_name
  }

}


build {

  sources = ["source.amazon-ebs.this"]

  provisioner "ansible" {

    playbook_file = "ansible/playbook.yml"
    user          = "ec2-user"
    use_sftp      = false

    ansible_env_vars = [
      "PYTHONUNBUFFERED=1",
      "ANSIBLE_SCP_IF_SSH=True",
      "FSX_USERNAME=${var.fsx_username}",
      "FSX_PASSWORD=${var.fsx_password}",
      "FSX_DOMAIN=${var.fsx_domain}",
      "FSX_CREDS=${var.fsx_creds}",
      "FSX_IP_ADDRESS=${var.fsx_ip_address}",
      "FSX_FILE_SHARE=${var.fsx_file_share}",
      "FSX_MOUNT_POINT=${var.fsx_mount_point}",
      "FSX_CIFS_MAX_BUF_SIZE=${var.fsx_cifs_max_buf_size}",
      "FSX_USERS=${var.fsx_users}"
    ]

  }

  post-processor "manifest" {
    output = local.packer_manifest
  }

}
