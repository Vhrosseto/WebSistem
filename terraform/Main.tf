provider "aws" {
  region = "us-west-2" # Substitua pela região desejada
}

# Route 53 (DNS)
resource "aws_route53_zone" "healthtrack_zone" {
  name = "healthtrack.com"
}

# Security Group para os Servidores EC2 e Load Balancer
resource "aws_security_group" "healthtrack_sg" {
  name_prefix = "healthtrack-sg"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer (ELB)
resource "aws_lb" "healthtrack_lb" {
  name               = "healthtrack-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.healthtrack_sg.id]
  subnets            = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"] # Substitua pelos seus Subnets

  enable_deletion_protection = false
}

# EC2 Instances (App Servers)
resource "aws_instance" "app_server" {
  count = 3
  
  ami           = "ami-0abcdef1234567890" # Substitua pela AMI correta
  instance_type = "t2.micro"
  key_name      = "healthtrack-keypair" # Substitua pela sua keypair

  vpc_security_group_ids = [aws_security_group.healthtrack_sg.id]
  subnet_id              = "subnet-0123456789abcdef0" # Substitua pelo seu Subnet
  
  tags = {
    Name = "HealthTrackAppServer-${count.index + 1}"
  }
}

# SNS Topic (Notification Queue)
resource "aws_sns_topic" "healthtrack_notifications" {
  name = "HealthTrackNotifications"
}

# Lambda Functions (Processors)
resource "aws_lambda_function" "activity_processor" {
  function_name = "ActivityProcessor"
  s3_bucket     = "healthtrack-lambda-code" # Substitua pelo seu bucket S3 onde o código Lambda está armazenado
  s3_key        = "activity_processor.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = "arn:aws:iam::123456789012:role/lambda-execution-role" # Substitua pelo ARN do papel IAM correto

  timeout   = 60
  memory_size = 128

  description = "Activity Processor for HealthTrack"
}

resource "aws_lambda_function" "sleep_processor" {
  function_name = "SleepProcessor"
  s3_bucket     = "healthtrack-lambda-code"
  s3_key        = "sleep_processor.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = "arn:aws:iam::123456789012:role/lambda-execution-role"

  timeout   = 60
  memory_size = 128

  description = "Sleep Processor for HealthTrack"
}

resource "aws_lambda_function" "hydration_processor" {
  function_name = "HydrationProcessor"
  s3_bucket     = "healthtrack-lambda-code"
  s3_key        = "hydration_processor.zip"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = "arn:aws:iam::123456789012:role/lambda-execution-role"

  timeout   = 60
  memory_size = 128

  description = "Hydration Processor for HealthTrack"
}

# S3 Bucket (Health Data Bucket)
resource "aws_s3_bucket" "healthtrack_data_bucket" {
  bucket = "healthtrack-data-bucket"
}

# RDS Instance (User Data DB)
resource "aws_db_instance" "healthtrack_db" {
  identifier        = "healthtrack-db"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t2.micro"
  name              = "HealthTrackDB"
  username          = "admin"
  password          = "yourpassword" # Substitua pela senha desejada
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.healthtrack_sg.id]
  availability_zone      = "us-west-2a" # Substitua pela zona de disponibilidade desejada
}
