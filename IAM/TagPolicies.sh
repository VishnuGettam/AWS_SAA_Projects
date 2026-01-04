#Tag Policies are a governance feature of AWS Organizations used to standardize and enforce tag keys
#and allowed values across multiple AWS accounts.

#Tag Policy to enforce specific tag keys and allowed values for resources in AWS accounts.
#This example enforces the "Environment" tag key with allowed values "Prod", "Sandbox
{
  "tags": {
    "Environment": {
      "tag_key": {
        "@@assign": "Environment"
      },
      "tag_value": {
        "@@assign": [
          "Prod",
          "Sandbox",
          "Security"
        ]
      }
    }
  }
}

#Tag Polcicy to enforce specific tag keys and allowed values for resources in AWS accounts.
# SCP + tag conditions

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyIfEnvironmentTagMissing",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "s3:CreateBucket",
        "rds:CreateDBInstance"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:RequestTag/Environment": "true"
        }
      }
    }
  ]
}
# Deny resource creation if the "Environment" tag with defined values is not provided
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyIfEnvironmentTagInvalid",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "s3:CreateBucket",
        "rds:CreateDBInstance"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestTag/Environment": [
            "Prod",
            "Sandbox",
            "Security"
          ]
        }
      }
    }
  ]
}