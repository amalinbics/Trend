variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile name"
  type        = string
}

variable "key_name" {
  type        = string
  default     = "jenkins-server-key"
}

variable "public_key_path" {
  type        = string
   default    = "./ec2/ssh-key/rsa-public.pub"
}

variable "ami" {
  type        = string
  default     = "ami-02d26659fd82cf299"
}

variable "instance_type"{
  type        = string
  default     = "t2.medium"
}

variable "user_data_path" {
  type        = string
  default     = "./ec2/userdata.sh"
}