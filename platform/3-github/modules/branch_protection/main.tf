# ====================================================================
# GitHub Branch Protection Rules Configuration
# ====================================================================

# Branch protection for master branch (moderate protection for development)
resource "github_branch_protection" "master" {
  repository_id           = var.repository.id
  pattern                 = "master"
  enforce_admins          = true
  require_signed_commits  = false
  required_linear_history = true #block merge commits
  allows_deletions        = false
  allows_force_pushes     = false

  required_status_checks {
    strict   = true
    contexts = var.master_branch_protection.required_status_checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    restrict_dismissals             = false
    required_approving_review_count = var.master_branch_protection.required_approving_review_count
    require_code_owner_reviews      = false
  }
}
