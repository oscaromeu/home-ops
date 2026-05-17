provider "github" {
  owner = var.github_owner
  # Token is read from GITHUB_TOKEN env var (loaded by Taskfile from secrets.sops.yaml).
  # The token must be a classic PAT with `repo` and `admin:org` (or equivalent fine-grained
  # permissions: Repository → Administration RW, Repository → Secrets RW, plus access to
  # manage the GitHub App installation owner account).
}
