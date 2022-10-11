locals {
  user_data = <<-EOT
#!/bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php
sudo yum install php-mbstring php-xml -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php
cd phpMyAdmin
mv config.sample.inc.php config.inc.php
sed -i 's/localhost/${aws_db_instance.database_instance.address}/g' config.inc.php
  EOT
}

# create ec2  instance jump-server
resource "aws_instance" "jump" {
  ami           = var.image_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.jump-public[0].id
  //subnet_id = aws_subnet.jump-public.id
  vpc_security_group_ids      = [aws_security_group.allow_tls_jump.id]
  associate_public_ip_address = true

  tags = {
    Name = "jump-server"
  }

  provisioner "file" {
    source      = "./aws-task-key-ohio.pem"
    destination = "/home/ec2-user/aws-task-key-ohio.pem"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("./aws-task-key-ohio.pem")
    }
  }
}

#create ec2 instance app-server
resource "aws_instance" "app" {
  ami                         = var.image_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.app-private[count.index].id
  vpc_security_group_ids      = [aws_security_group.allow_tls_app.id]
  associate_public_ip_address = false
  user_data                   = base64encode(local.user_data)
  count                       = 2

  tags = {
    Name = "app-Server"
  }
}
