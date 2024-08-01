variable  "project" {
  type        = string
  default     = "rhy"
  description = "The project name"
}

variable  "environment" {
  type        = string
  default     = "dev"
  description = "The environment to release"
}

variable  "location" {
  type        = string
  default     = "East US 2"
  description = "The location of the resources"
}

variable  "tags" {
  type        = map(string)
  default     = {
    environment = "dev"
    project     = "rhy"
    created_by  = "terraform"
  }
  description = "The tags to associate with the resources"
}

variable  "password" {
  type        = string
  description = "The password for the SQL Server"
  sensitive   = true
}
