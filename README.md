# ecs-linux-fsx-ami

Packer template for an Amazon Linux 2 ECS-optimized AMI with FSx Windows File System mounts for a set of system UIDs.

This is intended to be used as part of the following architecture (see Terraform module [andreswebs/ecs-fsx-sftp/aws](https://registry.terraform.io/modules/andreswebs/ecs-fsx-sftp/aws/latest)):

![Example SFTP service](https://raw.githubusercontent.com/andreswebs/terraform-aws-ecs-fsx-sftp/main/docs/img/ecs-fsx-sftp.svg)

The image contains a directory with mount points under `/mnt/fsx` (default) for a range of UIDs starting from `1001` (default).

## Configuration

The image is configured with environment variables which must be set when running `packer build`.

The variables:

- `FSX_IP_ADDRESS`: FSx "preferred IP address" property; default: "127.0.0.1" (dummy value)
- `FSX_FILE_SHARE`: name of the FSx Windows file share; default: "share"
- `FSX_SMB_VERSION`: SMB protocol version; default: "3.0" (use this value)
- `FSX_MOUNT_POINT`: base directory for user mount points; default: "/mnt/fsx"
- `FSX_CIFS_MAX_BUF_SIZE`: CIFS maximum buffer size; find it with the command: `modinfo cifs | grep CIFSMaxBufSize`;default: "130048"
- `FSX_USERNAME`: FSx Windows admin username, with permissions on the file share; default: "linux-fsx"
- `FSX_PASSWORD`: FSx Windows admin password
- `FSX_CREDS`: FSx credentials file, will contain the `FSX_USERNAME` and `FSX_PASSWORD`; default: "/home/ec2-user/.fsx-credentials"
- `FSX_DOMAIN`: FSx Windows file share domain name
- `FSX_USERS`: Comma-separated list of Unix user names with mount points from the FSx file share; default: "sftp-user"
- `FSX_UID_START`: Starting Unix UID for the `FSX_USERS`, incremented by 1 for each user; default: "1001"

## TODO

- create example `Jenkinsfile`

## Authors

**Andre Silva** - [@andreswebs](https://github.com/andreswebs)

## License

This project is licensed under the [Unlicense](UNLICENSE.md).
