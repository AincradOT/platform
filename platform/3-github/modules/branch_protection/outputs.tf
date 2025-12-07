output "protection_rules" {
  description = "Branch protection rules applied to repository branches"
  value = {
    master = {
      repository_id           = github_branch_protection.master.repository_id
      pattern                 = github_branch_protection.master.pattern
      enforce_admins          = github_branch_protection.master.enforce_admins
      require_signed_commits  = github_branch_protection.master.require_signed_commits
      required_linear_history = github_branch_protection.master.required_linear_history
      required_approving_reviews = (
        length(github_branch_protection.master.required_pull_request_reviews) > 0 ?
        github_branch_protection.master.required_pull_request_reviews[0].required_approving_review_count :
        0
      )
    }
  }
}
