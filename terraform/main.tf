# Get AWS Account ID
data "aws_caller_identity" "current" {}

# ---------------------------
# S3 Buckets
# ---------------------------
resource "aws_s3_bucket" "raw_data" {
  bucket = "csv-raw-data-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "processed_data" {
  bucket = "csv-processed-data-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "final_data" {
  bucket = "csv-final-data-${data.aws_caller_identity.current.account_id}"
}

# ---------------------------
# IAM Role for Lambda
# ---------------------------
resource "aws_iam_role" "lambda_role" {
  name = "Lambda-S3-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "S3-Data-Processing"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid      = "Statement1",
      Effect   = "Allow",
      Action   = ["s3:*", "s3-object-lambda:*"],
      Resource = [
        "${aws_s3_bucket.raw_data.arn}/*",
        "${aws_s3_bucket.processed_data.arn}/*",
        "${aws_s3_bucket.final_data.arn}/*"
      ]
    }]
  })
}

# ---------------------------
# IAM Role for Glue
# ---------------------------
resource "aws_iam_role" "glue_role" {
  name = "Glue-Service-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_exec" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "S3-Data-Processing"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid      = "Statement1",
      Effect   = "Allow",
      Action   = ["s3:*", "s3-object-lambda:*"],
      Resource = [
        "${aws_s3_bucket.raw_data.arn}/*",
        "${aws_s3_bucket.processed_data.arn}/*",
        "${aws_s3_bucket.final_data.arn}/*"
      ]
    }]
  })
}

# ---------------------------
# Package Lambda source
# ---------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../src/preprocessing_function/preprocessing_lambda.py"
  output_path = "../src/preprocessing_function/preprocessing_lambda.zip"
}

# ---------------------------
# Lambda Function
# ---------------------------
resource "aws_lambda_function" "csv_preprocessor" {
  function_name = "CSVPreprocessorFunction"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.13"
  handler       = "preprocessing_lambda.lambda_handler"
  filename      = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_data.bucket
    }
  }
}

# ---------------------------
# S3 Event Trigger for Lambda
# ---------------------------
resource "aws_s3_bucket_notification" "raw_upload_trigger" {
  bucket = aws_s3_bucket.raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_preprocessor.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "raw/"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_preprocessor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data.arn
}
