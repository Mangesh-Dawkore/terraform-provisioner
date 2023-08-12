
data "aws_vpc" "main" {
  id = "vpc-0f393ee365fb4b1ac"
}

data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoG+JmdsRTPXhgNvu/lY5NWbn2DijhzRHiKQQhLwa/O9MzzDx3ta1rQMGsC+s0Wq53L4Lc9tdw1RLOtNDlhUpq323dl7S3JGiy4aVdn756kg+OGR5LWLa4P8rQ0uxdgC6XrYSknTcoW0RXR4BF5r3YpcMUeJYtg8M07k6t5nMpCR+l9rbLmLzfW447ncM4rBVKscKrKPb5GdkgODeNe2y2P8+IZaAoWdyBkmmMz9V9TPTQtDfiajqb74n3imm5bK4dPiFnZeEb/XNfoLRYdovnLUYwT5gAKLA9YUgoM9Rv27ILL9qyXlIKO9wlZVDY8zAo5WOZm8VDbttS6tp1TabQrIo0FVvoqtgFis6O+ohqg1I0KrhomRfrIx5KMHf4ipQG0vrHhqC1cR4KXV4dsP68Kb4TGfZaMAXbYW5eNInVBxGca9hTVPJPvnTKaTMN5ZADuBXR+VUTTjFlxiIx8ZN5ezJmqhIq8kZ8i+DGHMaozcmcXY+3mtlFXEVjQykC7Q8= Dell@DESKTOP-M5QBV49"
}

resource "aws_instance" "my_server" {
  ami           = "ami-021f7978361c18b01"
  instance_type = "t2.micro"
  user_data     = data.template_file.user_data.rendered
  key_name      = aws_key_pair.deployer.key_name
  tags = {
    Name = "myserver"
  }
  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = "${file("C:\\Users\\Dell\\.ssh\\id_rsa")}"
    }
  }
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "my_security_group"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    description      = "outgoing taffic"
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}