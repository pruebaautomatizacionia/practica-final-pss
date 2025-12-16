```hcl
# Nombre: terraform_aws_eks_cluster.tf
# Ejemplo 1: Configuración básica de un clúster de Amazon EKS

provider "aws" {
  region = "us-east-1"
}

# Se asume que el proveedor de AWS y la configuración de autenticación ya están definidos.
# También se asume que existe una VPC y subredes.

data "aws_caller_identity" "current" {} # Obtiene información sobre la cuenta AWS actual

locals {
  cluster_name = "my-eks-cluster-${data.aws_caller_identity.current.account_id}"
  cluster_version = "1.28" # Versión de Kubernetes para el clúster
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "my_eks" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = local.cluster_version

  vpc_config {
    # Reemplaza con los IDs de tu VPC y subredes existentes
    subnet_ids = ["subnet-0abcdef1234567890", "subnet-0fedcba9876543210"] 
    public_access = true # Permite la comunicación con el endpoint de la API desde fuera de la VPC (ajusta para producción)
  }

  tags = {
    Name = local.cluster_name
    Environment = "Development"
  }
}

# Se necesita un nodo de trabajo para que el clúster sea funcional.
# Aquí se crea un grupo de nodos administrado por EKS.
resource "aws_iam_role" "eks_node_group_role" {
  name = "${local.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.my_eks.name
  node_group_name = "${local.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = ["subnet-0abcdef1234567890", "subnet-0fedcba9876543210"] # Mismas subredes que el clúster

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Opcional: Puedes especificar una AMI específica o dejar que EKS la gestione.
  # ami = "ami-xxxxxxxxxxxxxxxxx" 

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
  ]
}

output "eks_cluster_name" {
  description = "El nombre del clúster EKS."
  value       = aws_eks_cluster.my_eks.name
}

output "eks_cluster_endpoint" {
  description = "El endpoint de la API del clúster EKS."
  value       = aws_eks_cluster.my_eks.endpoint
}

# Nombre: terraform_aws_lambda_function.tf
# Ejemplo 2: Crear una función Lambda simple en AWS y un trigger API Gateway

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role-example"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world_lambda" {
  filename         = "lambda_functions/hello_world.zip" # Archivo ZIP de tu función Lambda. Necesitas crearlo.
  function_name    = "hello-world-lambda-example"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler" # El archivo y la función a ejecutar (ej. index.js, main.py)
  runtime          = "python3.9" # O el runtime que prefieras, e.j., nodejs18.x, java11

  source_code_hash = filebase64sha256("lambda_functions/hello_world.zip") # Para que Terraform detecte cambios

  environment {
    variables = {
      MY_ENV_VAR = "some_value"
    }
  }

  tags = {
    Name = "HelloWorldLambda"
    Project = "TerraformExamples"
  }
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "my-lambda-api"
  description = "API Gateway para acceder a la función Lambda"
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}" # Captura cualquier ruta
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY" # Acepta cualquier método HTTP (GET, POST, etc.)
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  type                    = "AWS_PROXY" # Integración Lambda proxy
  integration_http_method = "POST" # El método que API Gateway usa para llamar a Lambda
  uri                     = aws_lambda_function.hello_world_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  lifecycle {
    create_before_destroy = true # Asegura que la implementación anterior se elimine antes de crear una nueva
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "prod" # Nombre del entorno (ej. 'dev', 'staging', 'prod')
}

# Otorgar permiso a API Gateway para invocar la función Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gateway.id}/*/${aws_api_gateway_method.proxy_method.http_method}${aws_api_gateway_resource.proxy_resource.path}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {} # Necesario para el ARN de la fuente

output "api_gateway_url" {
  description = "URL para acceder a la función Lambda a través de API Gateway."
  value       = aws_api_gateway_stage.api_stage.invoke_url
}

# NOTA: Según las instrucciones de formato críticas, solo se debe generar código Terraform (.tf).
# La inclusión de código Ansible no es posible en este contexto, ya que pertenece a un formato y agente diferente.
```