resource "aws_iam_instance_profile" "bastion_profile1" {
  name = "bastion_profile1"
  role = aws_iam_role.KubernetesAdminRole.name
}
resource "aws_iam_role" "KubernetesAdminRole" {
  name                  = "cluster_admin"
  path                  = "/"
  description           = "Provides access to kubernetes admin users."
  force_detach_policies = false
  # tags                  = var.tags
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

  depends_on = [
    aws_iam_policy.KubernetesAdminPolicy
  ]

}

resource "aws_iam_policy" "KubernetesAdminPolicy" {
  name        = "admin-cluster-policy"
  path        = "/"
  description = "KubernetesAdmin policy to access kubernetes cluster"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "eks:DescribeCluster",
              "eks:ListClusters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cluster_admin"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "KubernetesAdminRole" {
  role       = aws_iam_role.KubernetesAdminRole.name
  policy_arn = aws_iam_policy.KubernetesAdminPolicy.arn

  depends_on = [
    aws_iam_policy.KubernetesAdminPolicy,
    aws_iam_role.KubernetesAdminRole
  ]
}
