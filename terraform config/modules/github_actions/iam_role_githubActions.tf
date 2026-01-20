####################################################################
# Create an AWS IAM role for GitHub Actions so that github actions
# can perform ssm and ec2 describe actions in my aws account 
####################################################################

# Create Identity Provider

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    # GitHub’s OIDC thumbprint
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# Trust Policy

data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:KingstonLtd/manage-jenkins:*"]
    }
  }
}

# Github actions IAM role and attach trust policy
resource "aws_iam_role" "github_actions_ssm_role" {
  name               = "GitHubActionsSSMRole"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json
}

# create the access policy

data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations",
      "ssm:GetCommandInvocation",
      "ec2:DescribeInstances"
    ]
    resources = ["*"] # Restrict to instance ARN later
  }

/*
  # if you also need secrets manager:
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:us-west-2:058264198774:secret:github-ttoken-nlcJZv"
    ]
  }
  */
}

# Assign the access policy a name
resource "aws_iam_policy" "github_actions_policy" {
  name   = "GitHubActionsSSMPolicy"
  description = "A policy for Github Actions to use ssm and and ec2-describe"
  policy = data.aws_iam_policy_document.github_actions_permissions.json
  tags        = var.tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "github_attach" {
  role       = aws_iam_role.github_actions_ssm_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
