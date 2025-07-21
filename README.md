# Terraform AWS FastAPI ECS Module

## Purpose
Reusable module to deploy FastAPI on AWS ECS (EC2 free-tier) with ALB and API Gateway.

## Inputs
| Variable    | Description          | Default | Required |
|-------------|----------------------|---------|----------|
| app_name    | Application Name      | None    | Yes      |
| ecr_image   | ECR Image URI         | None    | Yes      |
| desired_count | Number of EC2 Instances | 1    | No       |

## Outputs
| Output               | Description                     |
|-----------------------|---------------------------------|
| api_gateway_endpoint  | Public API Gateway HTTP Endpoint |
| alb_dns_name          | ALB DNS Name                    |

## Example
```hcl
module "fastapi" {
  source      = "github.com/your-org/terraform-aws-fastapi-ecs"
  app_name    = "my-fastapi-app"
  ecr_image   = "123456789012.dkr.ecr.us-east-1.amazonaws.com/fastapi:latest"
  desired_count = 1
}
