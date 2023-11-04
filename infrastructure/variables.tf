variable "aws_access_key_id" {
  description = "Access key to AWS console"
}

variable "aws_secret_access_key" {
  description = "Secret key to AWS console"
}

variable "aws_session_token" {
  description = "Session token to AWS console"
}

variable "key_pair_name_orchestrator" {
  description = "Key pair name for the orchestrator instance"
}

variable "key_pair_name_workers" {
  description = "Key pair name for the worker instances"
}
