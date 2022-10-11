###### vpc##########
resource "aws_vpc" "aws-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# jump public subnet
resource "aws_subnet" "jump-public" {
  vpc_id     = aws_vpc.aws-vpc.id
  //cidr_block = var.cidr[count.index]
  cidr_block = var.jump_pub_cidr[count.index]
  availability_zone = var.az[count.index]
  count = 2

  tags = {
    Name = "jump-public-sn"
  }
}

# app private subnet
resource "aws_subnet" "app-private" {
  vpc_id            = aws_vpc.aws-vpc.id
  cidr_block        = var.app_pvt_cidr[count.index]
  availability_zone = var.az[count.index]
  count             = 2

  tags = {
    Name = "app-private-sn"
  }
}

# db private subnet
resource "aws_subnet" "db-private" {
  vpc_id            = aws_vpc.aws-vpc.id
  cidr_block        = var.db_pvt_cidr[count.index]
  availability_zone = var.az[count.index]
  count             = 2

  tags = {
    Name = "db-private-sn"
  }
}

data "aws_subnets" "sid" {
  filter {
    name         = "vpc-id"
    values       = [aws_vpc.aws-vpc.id]
  }

  tags = {
    Tier = "Public"
  }
}

########### internet gateway ############
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name = "aws-igw"
  }
}

# elastic ip
resource "aws_eip" "myeip" {
  //instance = aws_instance.web.id
  vpc      = true
}


## Natgateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.jump-public[0].id

  tags = {
    Name = "aws-ngw"
  }

  depends_on = [aws_internet_gateway.igw]
}

###### route table ########
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "jump-pub-rt"
  }
}

resource "aws_route_table_association" "jump-rt" {
  subnet_id      = aws_subnet.jump-public[count.index].id
  route_table_id = aws_route_table.rtb.id
  count = 2
}


//Adding NAT Gateway into the default main route table
resource "aws_default_route_table" "dfltrtb" {
  default_route_table_id = aws_vpc.aws-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "app-pvt-rt"
  }
}

