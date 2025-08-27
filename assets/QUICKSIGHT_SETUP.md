Setup the Data Visualization with **Amazon QuickSight** in the AWS Management Console

**Create a QuickSight Account**
- Search **QuickSight** and select **Sign up for QuickSight**.
- Add email address in the **Email for account notifications** field.
- Select **Use IAM federated identities & QuickSight-managed users** under **Authentication method**.
- Add a **QuickSight** Account Name.
- Select **Use QuickSight-managed role (default)** under **IAM Role**.
- In the **Allow access and autodiscovery for these resources** section, select **Amazon S3** and add the previously created three S3 buckets.
- Uncheck the option **Add Pixel-Perfect Reports**.

**Connect to the Data Source**
- In QuickSight, select **New Dataset** under **Datasets**.
- Select **S3** as the data source.
	- Enter the Data Source Name: `ProcessedCSVData`
	- Manifest File- Edit the `../src/manifest.json` file and replace **ENTER YOUR OBJECT URL HERE** with the S3 object URL generated at the end of the steps in the **GLUE_SETUP.md** file. Upload this file to QuickSight. The `manifest.json` file should specify the S3 object URL of the transformed CSV file. Ensure the JSON syntax is valid (no trailing commas).  
	- Click **Connect**
- Select **Visualize**.

**Build and Publish a QuickSight Dashboard**
- Select **Add** under **Visuals** and select the `ProcessedCSVData` dataset.
- For this example, select the **Bar Chart** option.
	- For the X AXIS, select **timestamp_local**.
	- For the VALUE, select **app_temp (Sum)**.
- Select **Share** -> **Publish dashboard**
- Name the dashboard (e.g., `Weather Data Dashboard`).
- Choose users or groups to share with.

> Note: QuickSight is region-specific. Ensure you are working in the same AWS region as your S3 buckets.