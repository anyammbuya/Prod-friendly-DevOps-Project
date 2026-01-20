{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "sessionManagerServiceAccessPlusSSMRunCommandAccess",
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel",
                "ssm:UpdateInstanceInformation",

                "ssm:SendCommand",
                "ssm:ListCommands",
                "ssm:ListCommandInvocations",
                "ssm:GetCommandInvocation"  
        
            ],
            "Resource": "*"
        },
        {
            "Sid": "secretsManagerAccess",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "${adminpassARN}",
                "${PATarn}",
                "${deployKeyArn}"
            ]
        },
        {
            "Sid": "NecessaryForAwsSecretsManagerCredentialsProviderToWork",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3BucketLevelAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3ObjectWriteAccess",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::zeus-ec2ssm-logsbu/ssmlogs/*",
                "arn:aws:s3:::zeus-ec2ssm-logsbu/artifacts/*"
            ]
        },
        {
            "Sid": "KmsDecryptAccess",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "arn:aws:kms:${region}:${account_id}:key/${kms_key_id}"
        },
        {
            "Sid": "KmsGenerateDataKeyAccess",
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowDescribeInstancesForDockerhostLookup",
            "Effect": "Allow",
            "Action":[
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        }
    ]
}
