# Create IAM policy to allow put/get to the bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = ["s3:PutObject","s3:GetObject","s3:ListBucket"]
    resources = [
      aws_s3_bucket.app.arn,
      "${aws_s3_bucket.app.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "${var.project}-s3-policy"
  policy = data.aws_iam_policy_document.s3_policy.json
}

# IRSA role for service account (eks module already creates OIDC provider)
resource "aws_iam_role" "irsa_role" {
  name = "${var.project}-irsa-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = module.eks.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:default:app-writer"
        }
      }
    }]
  })
  tags = { Project = var.project }
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

output "irsa_role_arn" { value = aws_iam_role.irsa_role.arn }
output "cluster_name"  { value = module.eks.cluster_name }
output "region"        { value = var.region }
