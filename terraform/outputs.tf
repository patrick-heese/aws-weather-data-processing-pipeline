output "s3_raw_bucket_name" {
  value = aws_s3_bucket.raw_data.bucket
}

output "s3_processed_bucket_name" {
  value = aws_s3_bucket.processed_data.bucket
}

output "s3_final_bucket_name" {
  value = aws_s3_bucket.final_data.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.csv_preprocessor.function_name
}

output "lambda_role_name" {
  value = aws_iam_role.lambda_role.name
}

output "glue_role_name" {
  value = aws_iam_role.glue_role.name
}
