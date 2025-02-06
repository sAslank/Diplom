#main

variable "cloud_id" {
  description = "The cloud ID"
  type        = string
  default     = ************************************
}
variable "folder_id" {
  description = "The folder ID"
  type        = string
  default     = ************************************
}
variable "token_id" {
  description = "The token ID"
  type        = string
  default     = ***************************************************
}

#zone

variable "zone_a" {
  description = "The zone-a"
  type        = string
  default     = "ru-central1-a"
}


variable "zone_b" {
  description = "The zone-b"
  type        = string
  default     = "ru-central1-b"
}