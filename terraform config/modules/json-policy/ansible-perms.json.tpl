{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "sessionManagerServiceAccessPlusSessionStartSendCommandAccess",
            "Effect": "Allow",
            "Action": [

                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel",
                "ssm:UpdateInstanceInformation",

                "ssm:StartSession",
                "ssm:ResumeSession",
                "ssm:TerminateSession",
                "ssm:DescribeSessions",
                "ssm:SendCommand"

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
           "Sid": "SSMConnectionBucketAccess",
           "Effect": "Allow",
           "Action": [
             "s3:PutObject",
             "s3:GetObject",
             "s3:GetBucketLocation",
             "s3:ListBucket"
           ],
           "Resource": [
             "arn:aws:s3:::zeus-ec2ssm-logsbu",
             "arn:aws:s3:::zeus-ec2ssm-logsbu/*"
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
			"Action": [
				"ec2:DescribeInstances"
			],
			"Resource": "*"
		}

    ]
}
