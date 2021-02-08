{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2AllowDescribeCreateTags",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:CreateTags",
                "s3:Get*",
                "s3:List*"

            ],
            "Resource": "*"
        }
    ]
}