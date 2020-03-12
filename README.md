# Automated deployment of a Shadowsocks server on AWS

From 0 to fully fonctional Shadowsocks server in minutes, using [Terraform](https://www.terraform.io) and [Ansible](https://www.ansible.com). 

### Server details:
- **t2.micro** instance (Free Tier eligible).
- **Ubuntu 18.04**, with kernel tweaks and optimizations.

### Tested with :
- Terraform v0.12.23
- Ansible 2.9.2

### Variables to provide :

| Name  | Description |
| ----: | ----------- |
| aws_region | The AWS region where the server will be deployed (for example, ap-northeast-1). |
| aws_key_name | Name of the ssh key to be created |
| aws_public_key | Public key contents ("ssh-rsa AAAAB0CdeF1fg[...]") |
| instance_name | Name of the AWS instance to be created |
| private_key_file | Path to the private key file (\*.pem) |
| shadowsocks_pwd | Shadowsocks password |

