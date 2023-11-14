# ##################################################################################
# # DATA
# ##################################################################################

# data "aws_ssm_parameter" "amzn2_linux" {
#   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
# }

# # INSTANCES #
# resource "aws_instance" "nginx1" {
#   ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public_subnet1.id
#   vpc_security_group_ids = [aws_security_group.ec2_sg.id]

#   user_data = <<EOF
# #! /bin/bash
# sudo amazon-linux-extras install -y nginx1
# sudo service nginx start
# sudo rm /usr/share/nginx/html/index.html
# echo '<html><head><title>My Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Congrats -1</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
# EOF
# }


# # INSTANCES #
# resource "aws_instance" "nginx2" {
#   ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public_subnet2.id
#   vpc_security_group_ids = [aws_security_group.ec2_sg.id]

#   user_data = <<EOF
# #! /bin/bash
# sudo amazon-linux-extras install -y nginx1
# sudo service nginx start
# sudo rm /usr/share/nginx/html/index.html
# echo '<html><head><title>My Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Congrats - 2</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
# EOF
# }
