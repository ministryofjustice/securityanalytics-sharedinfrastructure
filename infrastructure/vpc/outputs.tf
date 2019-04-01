output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "subnets" {
  value {
    // Workaround from https://github.com/hashicorp/terraform/issues/12453#issuecomment-311611817
    instance = "${slice(
                concat(aws_subnet.private.*.id, aws_subnet.public.*.id),
                var.create_private ? 0 : length(aws_subnet.private.*.id),
                var.create_private ?
                    length(aws_subnet.private.*.id) :
                    length(aws_subnet.private.*.id) + length(aws_subnet.public.*.id))}"

    private = "${aws_subnet.private.*.id}"
    public  = "${aws_subnet.public.*.id}"
  }
}
