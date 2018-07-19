module "vpc" {
  source = "../public-only"

  # variables
  azs = "${ var.azs }"
  cidr = "${ var.cidr }"
  application = "${ var.application }"
  name = "${ var.name }"
  provisionersrc = "${ var.provisionersrc }"
}

resource "aws_eip" "nat" {
  count = "${ length(var.azs) }"
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  count = "${ length(var.azs) }"

  depends_on = [
    "module.vpc",
  ]

  allocation_id = "${ element( aws_eip.nat.*.id, count.index ) }"
  subnet_id = "${ module.vpc.subnet-ids-public[count.index] }"
}

resource "aws_subnet" "private" {
  count = "${ length( var.azs ) }"

  availability_zone = "${ element( var.azs, count.index ) }"
  cidr_block = "${ cidrsubnet(var.cidr, 4, count.index + length(var.azs)) }"
  vpc_id = "${ module.vpc.id }"

  map_public_ip_on_launch = "false"

  tags {
    Provisioner = "terraform"
    ProvisionerSrc = "${ var.provisionersrc }"
    Name = "${ var.name }-private"
    Application = "${ var.application }"
  }
}

resource "aws_route_table" "private" {
  count = "${ length( var.azs ) }"

  vpc_id = "${ module.vpc.id }"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${ element( aws_nat_gateway.nat.*.id, count.index ) }"
  }

  tags {
    Provisioner = "terraform"
    ProvisionerSrc = "${ var.provisionersrc }"
    Name = "${ var.name }-private"
    Application = "${ var.application }"
  }
}

resource "aws_route_table_association" "private" {
  count = "${ length(var.azs) }"

  route_table_id = "${ element( aws_route_table.private.*.id, count.index ) }"
  subnet_id = "${ element( aws_subnet.private.*.id, count.index ) }"
}
