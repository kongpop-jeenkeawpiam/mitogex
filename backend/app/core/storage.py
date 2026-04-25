import boto3
from botocore.config import Config
from app.core.config import settings

def get_s3_client():
    return boto3.client(
        's3',
        endpoint_url=settings.S3_ENDPOINT,
        aws_access_key_id=settings.S3_ACCESS_KEY,
        aws_secret_key_id=settings.S3_SECRET_KEY,
        config=Config(signature_version='s3v4'),
        region_name='us-east-1' # Generic region for SeaweedFS
    )

def generate_presigned_upload_url(object_name: str, expiration=3600):
    s3_client = get_s3_client()
    try:
        response = s3_client.generate_presigned_url(
            'put_object',
            Params={'Bucket': settings.S3_BUCKET, 'Key': object_name},
            ExpiresIn=expiration
        )
    except Exception as e:
        print(f"Error generating presigned URL: {e}")
        return None
    return response

def ensure_bucket_exists():
    s3_client = get_s3_client()
    try:
        s3_client.head_bucket(Bucket=settings.S3_BUCKET)
    except:
        s3_client.create_bucket(Bucket=settings.S3_BUCKET)
