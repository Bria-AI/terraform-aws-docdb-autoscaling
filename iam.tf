resource "aws_iam_role" "lambda" {
  name = "${var.name}-${local.region}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda" {
  name = "${var.name}-${local.region}-policy"
  path = "/"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
	Resource : [
	  "${aws_cloudwatch_log_group.scaleup.arn}:*",
	  "${aws_cloudwatch_log_group.scaledown.arn}:*",
	]
        Effect : "Allow"
      },
      {
        Action : [
          "logs:PutLogEvents"
        ],
	Resource : [
	  "${aws_cloudwatch_log_group.scaleup.arn}:*:*",
	  "${aws_cloudwatch_log_group.scaledown.arn}:*:*",
	]
        Effect : "Allow"
      },
      {
        Action : [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:rds:${local.region}:${local.account_id}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}
