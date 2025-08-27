Setup the Data Transformation with **AWS Glue** in the AWS Management Console

**Create Glue Data Catalog & Crawler**
- Select **Databases** under **Data Catalog**. Click **Add Database**.
- Enter the Database **Name**: `csv_data_pipeline_catalog`
- Click **Create database**.
- Select **Crawlers** under **Data Catalog**. Click **Create crawler**.
  - Enter the Crawler **Name**: `ProcessedCSVDataCrawler`
  - Click **Next**.
  - Select **Add a data source**.
	- Choose **S3** as the Data source.
	- **S3 path**: Enter the location of the `csv-processed-data` bucket.
  - Click **Next**.
  - Select the `Glue-Service-Role` for the **Existing IAM role**.
  - Click **Next**.
  - Select the **Target database**: `csv_data_pipeline_catalog`
  - Select **Run on demand** for the **Crawler schedule Frequency** (this avoids unnecessary costs during testing).
  - Click **Next**.
  - Click **Create crawler**.
- Select the newly created Crawler and click **Run**. The crawler will take a few minutes to finish running.
- View the new table schema in **Tables** under **Data Catalog** | **Databases**.

**Create Glue Job using Visual ETL**
- Select **Visual ETL** under **Data Integration and ETL** | **ETL jobs**.
- Select **Visual ETL** under **Create job**
- At the top of the Visual canvas, enter the **Name**: `CSVDataTransformation`
- Under **Add nodes**, select **AWS Glue Data Catalog** 
- Under the **Database** field of the new node, select the newly created database: `csv_data_pipeline_catalog`
  - Select the **Table**: `csv_processed_data`.
- Click the **+** button and select **Transforms**
- Select **Change Schema**.
  - Under **Node parents**, select the **AWS Glue Data Catalog**.
  - Choose options under **Change Schema (Apply mapping)**. For this example, the `icon` column was dropped.
- Click the **+** button and select **Targets**
-  Select **Amazon S3**.
  - Under **S3 Target Location**, enter the S3 path of where the transformed CSV files will be stored: `csv-final-data`
  - **Format**: CSV
  - **Compression**: GZIP
  - Unselect **Check data quality**.
- Select **Job details** at the top of the Visual ETL Studio.
- Select the **IAM role**: `Glue-Service-Role`
- Click **Save**.
- Click **Run**.

**Prepare Data for Visualization**
> Note: In production, this step can be automated (e.g., Glue job outputting directly to `.csv.gz` with proper naming), but here it is manual for demonstration.

- Download the ZIP file in the `csv-final-data` S3 bucket.
- Extract and Rename the file to include a .csv extension at the end.
- Upload the file back to the S3 bucket.
- Copy the Object URL of the CSV file to use for QuickSight.