
resource "aws_security_group" "strapi-sg" {
  vpc_id      = aws_vpc.strapi_vpc.id
  description = "Security Group for Strapi Application"
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = "1337"
    to_port     = "1337"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Strapi-SG"
  }

}

resource "aws_instance" "strapi-ec2" {
  ami                         = var.ami
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.strapi-sg.id]
  subnet_id = aws_subnet.public_subnet1.id
  key_name                    = "devops"
  associate_public_ip_address = true
  user_data                   = <<-EOF
                                #!/bin/bash
                                sudo apt update
                                curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
                                sudo bash -E nodesource_setup.sh
                                sudo apt update && sudo apt install nodejs -y
                                sudo npm install -g yarn && sudo npm install -g pm2
                                echo -e "skip\n" | npx create-strapi-app simple-strapi --quickstart
                                cd simple-strapi
                                echo "const strapi = require('@strapi/strapi');
                                strapi().start();" > server.js
                                pm2 start server.js
                                sleep 360
                                EOF

  tags = {
    Name = "Strapi_ec2"
  }
}
