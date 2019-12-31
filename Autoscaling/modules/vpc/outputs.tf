output "public1_subnet" {
   #value = "${aws_subnet.public.*.id[count.index]}"
     #value = "${element(aws_subnet.public.*.id, 1)}"
     value="${aws_subnet.public1.id}"
 }
 output "public2_subnet" {
   #value = "${aws_subnet.public.*.id[count.index]}"
     #value = "${element(aws_subnet.public.*.id, 1)}"
     value="${aws_subnet.public2.id}"
 }
 output "vpc_id" {
   value="${aws_vpc.main.id}"
 }

output "security_group" {
  value = "${aws_security_group.example-test-sg.id}"
}