# Terraform Argument Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.39.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_control_plane"></a> [control\_plane](#module\_control\_plane) | ./modules/node | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./modules/security | n/a |
| <a name="module_worker"></a> [worker](#module\_worker) | ./modules/node | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [random_password.token_end](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.token_start](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.main](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_plane_private_ip"></a> [control\_plane\_private\_ip](#input\_control\_plane\_private\_ip) | Private IP of the Control Plane. | `string` | `"172.31.1.10"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name. | `string` | `"dev"` | no |
| <a name="input_ingress_access_cidr"></a> [ingress\_access\_cidr](#input\_ingress\_access\_cidr) | The IP address range allowed access to the cluster. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for the instance. | `string` | `"t3.medium"` | no |
| <a name="input_project"></a> [project](#input\_project) | The project name. | `string` | `"k8s"` | no |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | The Public Subnet CIDR block. | `string` | `"172.31.1.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region the infrastructure will be deployed in. | `string` | `"eu-central-1"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The VPC CIDR block. | `string` | `"172.31.0.0/16"` | no |
| <a name="input_worker_private_ip_start"></a> [worker\_private\_ip\_start](#input\_worker\_private\_ip\_start) | The beginning of each worker's private IP. | `string` | `"172.31.1."` | no |
| <a name="input_worker_suffixes"></a> [worker\_suffixes](#input\_worker\_suffixes) | The suffix appended to worker names and IPs. | `list(string)` | <pre>[<br>  "20",<br>  "21"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_plane_public_ip"></a> [control\_plane\_public\_ip](#output\_control\_plane\_public\_ip) | Public IP of the Control Plane. |
| <a name="output_k8s_token"></a> [k8s\_token](#output\_k8s\_token) | The token used to join workers to the control plane. |
| <a name="output_private_key"></a> [private\_key](#output\_private\_key) | The private key needed to SSH into the nodes. |
| <a name="output_worker_public_ip"></a> [worker\_public\_ip](#output\_worker\_public\_ip) | Public IP of the Workers. |
<!-- END_TF_DOCS -->

# Helper Commands

## Check bootstrap.sh progress

If this is the first time starting the node, make sure the `bootstrap.sh` script has finished running by checking the cloud-init log:

```bash
tail -f /var/log/cloud-init-output.log
```

## Install NGINX Ingress

The NGINX Ingress chart being installed comes from [here](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx). Run the following commands on the Control Plane:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade \
  --install ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.service.type="NodePort" \
  --set controller.service.nodePorts.http=30000 \
  --namespace ingress-nginx \
  --create-namespace \
  --wait \
  --atomic
```

If you add an Ingress resource and do not have a Load Balancer installed, you will have to edit your `/etc/hosts` file since Ingress accepts only hostnames and cannot accept IP addresses. For example, you could add the following entry in your hosts file:

```bash
123.456.789.101 someapp.com
```

In this case, you will have to provide the following host in the Ingress resource:

```yaml
spec:
  ingressClassName: nginx
  rules:
    - host: someapp.com
```
