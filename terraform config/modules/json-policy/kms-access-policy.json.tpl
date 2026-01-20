{
  "Version": "2012-10-17",
  "Id": "secure-kms-policy",
  "Statement": [
    {
      "Sid": "Allow Key Administrators",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account_id}:user/yoshi"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow Secrets Manager to use the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${account_id}",
          "kms:ViaService": "secretsmanager.${region}.amazonaws.com"
        }
      }
    },
    {
      "Sid": "Allow SSM to use the key for sessions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${account_id}",
          "kms:ViaService": "ssm.${region}.amazonaws.com"
        }
      }
    },
    {
    "Sid": "Allow EC2 Instance Role to use the key",
    "Effect": "Allow",
    "Principal": {
       "AWS": [
            "arn:aws:iam::${account_id}:role/${jenkinsiamrole}",
            "arn:aws:iam::${account_id}:role/${k8siamrole}",
            "arn:aws:iam::${account_id}:role/${ansibleiamrole}" 
        ]
    },
    "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ],
    "Resource": "*"
   }
 ]
}