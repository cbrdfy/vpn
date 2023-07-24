## Terraform script to deploy VPN server on AWS

To deploy your own VPN on AWS server you will need:
  1. Register an AWS account.
  2. Install terraform [binary](https://developer.hashicorp.com/terraform/downloads).

After configuring your Access and Secret keys I suggest to export them as environment variables:
```
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
export AWS_DEFAULT_REGION=region where you want to deploy your VPN
```

To deploy a VPN server on AWS Cloud:
```
terraform init
terraform plan
terraform apply
```

[s3fs](https://github.com/s3fs-fuse/s3fs-fuse) is used to mount an S3 bucket and use it as local disk. So you can just visit your AWS account and download needed config file. However, there is another method to get your config file by pulling it from the EC2 server using `scp`:

`scp -i {path_to_ssh_key_for_EC2} admin@{EC2_external_ip}:/mnt/{bucket_name}/{path_to_your_config_file} {where_to_save_config_locally}`

Planning to create a Lambda function that will trigger on server creation and automatically push config files to S3 instead of using s3fs.

Terraform script deploys VPN using these resources:
```
data.aws_ami.latest_debian
aws_eip.vpn_static_ip
aws_iam_instance_profile.ec2_profile
aws_iam_policy.s3_access
aws_iam_role.ec2_role
aws_iam_role_policy_attachment.attach_ec2_s3
aws_instance.vpn_server
aws_internet_gateway.gw
aws_key_pair.nvirginia
aws_route_table.vpn_pub_rt
aws_route_table_association.public[0]
aws_s3_bucket.wg-vpn-bucket
aws_s3_object.config_object
aws_security_group.allow_vpn_udp
aws_subnet.public[0]
aws_vpc.vpn_vpc
```


