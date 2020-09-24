locals {
  # Common tags that can be used throughout other resources.
  common_tags = {
    "Project" : "Worldless",
    "Workspace" : terraform.workspace
  }
}
