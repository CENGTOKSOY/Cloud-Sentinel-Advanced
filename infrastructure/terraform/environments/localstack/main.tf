terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # 6.x yerine daha stabil olan 5.x kullanalım
    }
  }
}