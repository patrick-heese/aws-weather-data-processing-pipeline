import boto3
import csv
import io
import os

# Initialize S3 client
s3 = boto3.client('s3')

# Get processed bucket name from environment variable
processed_bucket = os.environ.get("PROCESSED_BUCKET")

def lambda_handler(event, context):
    # Get the bucket name and file key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']

    try:
        # Read the CSV file from S3
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        csv_content = response['Body'].read().decode('utf-8')

        # Process the CSV content
        processed_rows = []
        reader = csv.reader(io.StringIO(csv_content))
        header = next(reader, None)  # Handle empty files safely

        if header is None:
            print(f"File {file_key} is empty. Skipping processing.")
            return {"statusCode": 200, "body": "Empty file skipped."}

        for row in reader:
            # Example preprocessing: filter out rows with missing values
            if all(row):
                processed_rows.append(row)

        # Write processed data back to a new CSV in memory
        output_csv = io.StringIO()
        writer = csv.writer(output_csv)
        writer.writerow(header)  # Write the header row
        writer.writerows(processed_rows)

        # Replace prefix raw/ → processed/ to keep folder structure
        processed_file_key = file_key.replace("raw/", "processed/", 1)

        # Upload the processed file to the processed data bucket
        s3.put_object(
            Bucket=processed_bucket,
            Key=processed_file_key,
            Body=output_csv.getvalue()
        )

        print(f"Processed file uploaded to: {processed_bucket}/{processed_file_key}")
        return {"statusCode": 200, "body": "File processed successfully."}

    except Exception as e:
        print(f"Error processing file: {str(e)}")
        raise
