######################
# NAT Subnets
######################

resource "aws_eip" "nat_ip" {
  count = "${local.nat_az_count}"
  vpc   = true

  tags {
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = "${local.nat_az_count}"
  allocation_id = "${aws_eip.nat_ip.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"

  tags {
    Name      = "${var.app_name}-gw-${count.index}-${terraform.workspace}"
    app_name  = "${var.app_name}"
    workspace = "${terraform.workspace}"
  }
}
