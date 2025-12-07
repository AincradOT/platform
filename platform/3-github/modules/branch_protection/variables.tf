variable "repository" {
  description = "Repository details for branch protection configuration"
  type = object({
    id   = string
    name = string
  })
}

variable "master_branch_protection" {
  description = "Branch protection configuration for master branch"
  type = object({
    required_status_checks          = list(string)
    required_approving_review_count = number
  })
  default = {
    required_status_checks          = []
    required_approving_review_count = 0
  }
}
