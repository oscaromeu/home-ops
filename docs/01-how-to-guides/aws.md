## Create S3 Bucket

Create an S3 bucket, replacing placeholders appropiately

!!! tip
    Generate a random string with `openssl rand -hex 18`


```
BUCKET=<YOUR_BUCKET>
REGION=<YOUR_REGION>
APP=<YOUR_APP>
aws s3api create-bucket \
    --bucket $BUCKET \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION
```

__NOTE:__  us-east-1 does not support a `LocationConstraint`. If your region is `us-east-1`, omit the bucket configuration:

```
BUCKET=<YOUR_BUCKET>
REGION=<YOUR_REGION>
aws s3api create-bucket \
    --bucket $BUCKET \
    --region us-east-1
```

## Set permissions for the App with an IAM user

!!! Info

    The permissions for the app can be configured also using kube2iam method.


For more information, see [the AWS documentation on IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)

1. Create the IAM user:

```
aws iam create-user --user-name $APP
```

2. Attach policies to give `$APP` the necessary permissions

```
cat > $APP-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}"
            ]
        }
    ]
}
EOF
```

```
aws iam put-user-policy \
  --user-name $APP \
  --policy-name $APP \
  --policy-document file://$APP-policy.json
```

3. Create an access key for the user:

```
aws iam create-access-key --user-name $APP
```

The result should look like

```
{
  "AccessKey": {
        "UserName": "velero",
        "Status": "Active",
        "CreateDate": "2017-07-31T22:24:41.576Z",
        "SecretAccessKey": <AWS_SECRET_ACCESS_KEY>,
        "AccessKeyId": <AWS_ACCESS_KEY_ID>
  }
}
```
