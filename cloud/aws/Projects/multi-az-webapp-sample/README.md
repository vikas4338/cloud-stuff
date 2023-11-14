## highly-available-applocation
terraform Init
terraform plan -var db_table_name="state.lock" -var hash_key="LockID" -var s3_bucket_name="bucket-for-iac-vk"
terraform apply -var db_table_name="state.lock" -var hash_key="LockID" -var s3_bucket_name="bucket-for-iac-vk" --auto-approve
