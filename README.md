# Create Infra

## Check Prerequisites

- Terraform
- Generate a valid key-pair:

```bash
mkdir ssh
ssh-keygen -t rsa -b 4096 -f ssh/key -N '' -C 'key'
chmod 400 ssh/key*
```

- Create a Terraform TFVARS file and provide the IP address which will be able to access your instances:

```bash
touch terraform.tfvars
echo 'ingress_access_cidr = "<YOUR_IP>/32"' > terraform.tfvars
```

- The current setup uses a local backend. If you would like to use an s3 Terraform backed, for example, uncomment the lines in `tfstate.tf`. After that the Terraform init command will look like this:

```bash
terraform init \
  -backend-config "region=<REGION>" \
  -backend-config "bucket=<BUCKET_NAME>" \
  -backend-config "key=<STATE_FOLDER>/terraform.state"
```

## Execute Terraform Commands

```bash
terraform init

terraform validate

terraform plan

terraform apply
```

## SSH into a Node

```bash
ssh -i ssh/key ubuntu@<NODE_PUBLIC_IP>
```

If this is the first time starting the node, make sure the `bootstrap.sh` script has finished running by checking the following file on the node:

```bash
cat /var/log/cloud-init-output.log

# or
tail -f /var/log/cloud-init-output.log
```

The commands of `bootstrap.sh` should be outputted in the log so you can search for them. All commands would be appended by `+ ` (plus + space) i.e., you can also search for this symbol.

# Terraform Argument Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.57.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.control_plane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.worker_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.control_plane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_security_group_egress_rule.all_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.api_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_control_plane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_worker_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.node_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | Ubuntu 22.04 LTS from 2023-03-03. | `string` | `"ami-050096f31d010b533"` | no |
| <a name="input_control_plane_hostname"></a> [control\_plane\_hostname](#input\_control\_plane\_hostname) | Hostname the Control Plane. | `string` | `"control-plane"` | no |
| <a name="input_control_plane_private_ip"></a> [control\_plane\_private\_ip](#input\_control\_plane\_private\_ip) | Private IP of the Control Plane. | `string` | `"10.0.1.10"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name. | `string` | `"dev"` | no |
| <a name="input_ingress_access_cidr"></a> [ingress\_access\_cidr](#input\_ingress\_access\_cidr) | The IP address range allowed access to the cluster. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type. | `string` | `"t2.medium"` | no |
| <a name="input_project"></a> [project](#input\_project) | The project name. | `string` | `"k8s"` | no |
| <a name="input_pub_subnet_cidr"></a> [pub\_subnet\_cidr](#input\_pub\_subnet\_cidr) | The Public Subnet CIDR block. | `string` | `"10.0.1.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region the infrastructure will be deployed in. | `string` | `"eu-central-1"` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of the volume in gibibytes (GiB). | `number` | `50` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | The volume type. | `string` | `"gp2"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The VPC CIDR block. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_worker_1_hostname"></a> [worker\_1\_hostname](#input\_worker\_1\_hostname) | Hostname of Worker 1 Node. | `string` | `"worker-1"` | no |
| <a name="input_worker_1_private_ip"></a> [worker\_1\_private\_ip](#input\_worker\_1\_private\_ip) | Private IP of Worker 1 Node. | `string` | `"10.0.1.11"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_plane_public_ip"></a> [control\_plane\_public\_ip](#output\_control\_plane\_public\_ip) | Public IP of the Control Plane. |
| <a name="output_worker_1_public_ip"></a> [worker\_1\_public\_ip](#output\_worker\_1\_public\_ip) | Public IP of the Worker 1 Node. |
<!-- END_TF_DOCS -->

# Helper Commands

## Regenerate the Terraform Argument Reference

Use the [terraform-docs](https://terraform-docs.io/how-to/insert-output-to-file/) command to regenerate the Terraform Argument Reference if you add new variables or edit the existing ones:

```bash
terraform-docs markdown table --output-file README.md .
```
