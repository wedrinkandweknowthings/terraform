# terraform

Re-usable terraform modules 🍻

### Table of Contents

  - [**AWS**](#aws)
    - [VPC](#vpc)

# AWS

## VPC

Two modules for creating robust VPC configurations within AWS. Both setups are highly available, with subnets created in all availability zones offered by your chosen region.

### Public & Private Subnets

In most production use cases both public and private subnets will be required for your AWS resources. Consider a simple scenario where you have a ALB (load-balancer) and a two EC2s handling web requests. In this set up, good advice would be to place the ALB in the public subnet, and the EC2s in the private subnet.

~The module will create NAT gateway in each zone.~

N.B. Currently, only one NAT gateway is created - this should be rectified as it does not provide an HA solution.

 > NOTE - While the VPC and subnet configuration is free, NAT gateways are charged for, as [per the AWS pricing guide](https://aws.amazon.com/vpc/pricing/)
 
##### Usage

```HCL
data "aws_availability_zones" "available" {}

module "vpc" {
  source = "git@github.com:wedrinkandweknowthings/terraform.git?ref=0.0.1//vpc/public-private"

  name = "example-app-main-vpc"
  
  azs = "${ data.aws_availability_zones.available.names }"
  cidr = "172.31.0.0/16"
  
  # These values will be used to create resource tags
  application = "example-app"
  provisionersrc = "https://github.com/.../.../..." # Any link to the repo
}
```

### Public Subnets Only

In some specifc cases, you may wish to deploy only public subnets. This will avoid the charge for NAT instances, which are only required in private subnets containing resources that require access to the internet.

##### Usage

Configuration is almost identical to the public-private module above, simply change the module reference to `public-only`

```HCL
module "vpc" {
  source = "git@github.com:wedrinkandweknowthings/terraform.git?ref=0.0.1//vpc/public-only"
  
```
