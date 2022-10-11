variable "region" {
  description = "Region name"
  type        = string
  default     = "us-east-2"
}

variable "profile" {
  description = "Profile name"
  type        = string
  default     = "terraform-user"
}


variable "az" {
  description = "Availability Zones for VPC"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

### Variables for vpc
variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "aws-task-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# variable for public subnet  - jump-server
variable "jump_pub_cidr" {
  type = list
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

# variable for private subnet  - app-server
variable "app_pvt_cidr" {
  type = list
  default = ["10.0.3.0/24","10.0.4.0/24"]
}

# variable for private subnet  - db-server
variable "db_pvt_cidr" {
  type = list(string)
  default = ["10.0.5.0/24","10.0.6.0/24"]
}

# variable for jump-server ec2 instance

variable "image_ami" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = "ami-0f924dc71d44d23e2"
}

variable "instance_type" {
  description = "The type of the instance. If present then `instance_requirements` cannot be present"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = "aws-task-key-ohio"
}

### RDS
variable "database_sn_name" {
  description = " Name of database subnet"
  type = string
  default = "database_subnet"
}

variable "database_snapshot_identifier" {
  description = " The database snapshot"
  type = string
  default = "mysql57db-snapshot"
}

/*
variable "database_instance_class" {
  description = " The database instance type"
  type = string
  default = "db.t2.micro"
}*/

variable "database_instance_identifier" {
  description = " The database instance identifier"
  type = string
  default = "mysqldb57"
}
