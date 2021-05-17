resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_profile"
  role = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "jenkins-policy-attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

resource "aws_iam_policy" "jenkins_policy" {
  name        = "jenkins-policy"
  description = "A policy to work with ECR, EKS"

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"GetAuthorizationToken",
         "Effect":"Allow",
         "Action":[
           "eks:DescribeCluster",
           "eks:ListClusters",
           "iam:GetOpenIDConnectProvider",
           "iam:CreateOpenIDConnectProvider",
           "iam:CreatePolicy",
           "iam:DetachRolePolicy",
           "iam:CreateRole",
           "iam:GetRole",
           "iam:AttachRolePolicy",
           "cloudformation:ListStacks",
           "cloudformation:CreateStack",
           "cloudformation:DescribeStackEvents",
           "cloudformation:DescribeStacks",
           "ecr:GetAuthorizationToken"
         ],
         "Resource":"*"
      },
      {
         "Sid":"ManageRepositoryContents",
         "Effect":"Allow",
         "Action":[
                "ecr:BatchCheckLayerAvailability",
                "ecr:DescribeImages",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:BatchGetImage",
                "ecr:ListImages",
                "ecr:PutImage"
         ],
         "Resource":[
           "arn:aws:ecr:us-east-1:482720962971:repository/ecr_images_from_jenkins",
           "arn:aws:ecr:us-east-1:482720962971:repository/gateway"
         ]
      },
      {
        "Sid": "RunEC2Agents",
        "Action": [
                "ec2:DescribeSpotInstanceRequests",
                "ec2:CancelSpotInstanceRequests",
                "ec2:GetConsoleOutput",
                "ec2:RequestSpotInstances",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeRegions",
                "ec2:DescribeImages",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole"
                ],
            "Effect": "Allow",
            "Resource": "*"
        }
   ]
}
EOF
}
resource "aws_iam_instance_profile" "jenkins_slave_profile" {
  name = "jenkins_slave_profile"
  role = aws_iam_role.jenkins_slave_role.name
}

resource "aws_iam_role" "jenkins_slave_role" {
  name = "jenkins_slave_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "jenkins-slave-policy-attach" {
  role       = aws_iam_role.jenkins_slave_role.name
  policy_arn = aws_iam_policy.jenkins_slave_policy.arn
}

resource "aws_iam_policy" "jenkins_slave_policy" {
  name        = "jenkins-slave-policy"
  description = "A policy to work with ECR, EKS"

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"GetAuthorizationToken",
         "Effect":"Allow",
         "Action":[
           "ecr:GetAuthorizationToken"
         ],
         "Resource":"*"
      },
      {
         "Sid":"ManageRepositoryContents",
         "Effect":"Allow",
         "Action":[
                "ecr:BatchCheckLayerAvailability",
                "ecr:DescribeImages",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:BatchGetImage",
                "ecr:ListImages",
                "ecr:PutImage"
         ],
         "Resource":[
           "arn:aws:ecr:us-east-1:482720962971:repository/ecr_images_from_jenkins",
           "arn:aws:ecr:us-east-1:482720962971:repository/gateway"
         ]
      }
   ]
}
EOF
}
