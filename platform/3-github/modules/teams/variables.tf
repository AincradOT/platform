variable "teams" {
  description = "Teams configuration including members, maintainers, and privacy settings"
  type = map(object({
    description = string
    privacy     = optional(string, "closed")
    members     = optional(list(string), [])
    maintainers = optional(list(string), [])
  }))
}

variable "github_organization" {
  description = "GitHub organization name for team URL generation"
  type        = string
}
