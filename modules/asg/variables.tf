variable "project_name"         { type = string }
variable "ami_id"               { type = string }
variable "instance_type"        { type = string }
variable "key_name"             { type = string }
variable "security_group_id"    { type = string }
variable "iam_instance_profile" { type = string }
variable "public_subnet_ids"    { type = list(string) }
variable "target_group_arn"     { type = string }
variable "db_host"              { type = string }
variable "db_port"              { type = string }
variable "db_name"              { type = string }
variable "db_username"          { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "jwt_secret" {
  type      = string
  sensitive = true
}
variable "vault_secret" {
  type      = string
  sensitive = true
}
variable "frontend_url"         { type = string }
