provider "aws" {
    region = "ap-south-1"
}

module "rds" {
    source = "./modules/rds"
}

module "eks" {
    source = "./modules/eks"
    project = "cbz"
    desired_nodes = 1
    max_nodes  = 2
    min_nodes  = 1
    node_instance_type = "c7i-flex.large"
}

module "s3" {
    source = "./modules/s3"
    s3_bucket_name = "frontend-bucket-flight-app123"
}
output "aws_rds_endpoint" {
    value = module.rds.rds_endpoint
}
output "aws_s3_website_endpoint" {
    value = module.s3.website_endpoint
}