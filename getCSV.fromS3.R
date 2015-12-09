# This function gets csv data from AWS S3 buckets
getCSV.fromS3 <- function(bucket, object, region='eu-west-1') {
  require(aws.s3)
  require(jsonlite)
  require(httr)
  # Get temporary credentials for RserverRole
  req <- httr::GET("http://169.254.169.254/latest/meta-data/iam/security-credentials/analyticsSandboxServerRole",
                   httr::add_headers("Content-Type" = "application/json"))
  httr::stop_for_status(req)
  ec2metadata <- jsonlite::fromJSON((httr::content(req)))
  
  # Set credentials as environment variables
  Sys.setenv(AWS_TOKEN = paste(ec2metadata$Token),
             AWS_ACCESS_KEY_ID = paste(ec2metadata$AccessKeyId),
             AWS_SECRET_ACCESS_KEY = paste(ec2metadata$SecretAccessKey),
             AWS_DEFAULT_REGION = region)
  
  obj <- aws.s3::getobject(bucket=bucket, 
                        object=object,
                        headers = list('X-Amz-Security-Token' = Sys.getenv("AWS_TOKEN")),
                        region = Sys.getenv("AWS_DEFAULT_REGION"),
                        key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                        secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"))
  
  data <- read.csv(text=rawToChar(obj$content))
  return(data)
}
