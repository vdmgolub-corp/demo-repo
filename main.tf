provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

resource "aws_instance" "web_app" {
  ami           = "ami-674cbc1e"
  instance_type = "m5.4xlarge" # <<<<< Try changing this to m5.8xlarge to compare the costs

  root_block_device {
    volume_size = 50
  }

  ebs_block_device {
    device_name = "my_data"
    volume_type = "gp2" # <<<<< Try changing this to gp2 to compare costs
    volume_size = 500
    iops        = 800
  }
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world"
  role          = "arn:aws:lambda:us-east-1:account-id:resource-id"
  handler       = "exports.test"
  runtime       = "nodejs12.x"
  memory_size   = 512 # <<<<< Try changing this to 512 to compare costs
}

resource "aws_db_proxy" "example" {
  name                   = "example"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = "arn"

  auth {
    auth_scheme = "SECRETS"
    description = "example"
    iam_auth    = "DISABLED"
    secret_arn  = "arn"
  }

  tags = {
    Name = "example"
    Key  = "value"
  }
}

resource "aws_db_proxy_endpoint" "example" {
  db_proxy_name          = aws_db_proxy.example.name
  db_proxy_endpoint_name = "example"
  target_role            = "READ_ONLY"
}
