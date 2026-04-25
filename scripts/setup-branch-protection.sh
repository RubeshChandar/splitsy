#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# Setup branch protection rules for the Splitsy repository
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated
#   - You must have admin access to the repository
#
# What this script does:
#   1. Protects the 'main' branch
#   2. Requires pull request reviews (but allows self-approval)
#   3. Requires the CI workflow to pass before merging
#   4. Prevents direct pushes to main
# ──────────────────────────────────────────────────────────

set -euo pipefail

REPO="RubeshChandar/splitsy"
BRANCH="main"

echo "🔧 Setting up branch protection for '$BRANCH' on $REPO..."
echo ""

# ── Step 1: Create/Update branch protection rule ──
echo "📌 Applying branch protection ruleset..."

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/${REPO}/branches/${BRANCH}/protection" \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Lint & Format Check",
      "Backend Tests (Django)",
      "Frontend Tests (Next.js)",
      "FastAPI Tests (Notifications)",
      "Docker Build Check"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF

echo ""
echo "✅ Branch protection applied to '$BRANCH'!"
echo ""
echo "📋 Protection rules summary:"
echo "   • PRs required to merge into main"
echo "   • 1 approval required (self-approval allowed — see note below)"
echo "   • CI checks must pass before merging"
echo "   • Stale reviews dismissed on new commits"
echo "   • Linear history enforced (no merge commits)"
echo "   • Force pushes and branch deletion blocked"
echo "   • Admin enforcement disabled (admins can bypass)"
echo ""
echo "──────────────────────────────────────────────────────"
echo ""
echo "📝 IMPORTANT — To allow self-approval of your own PRs:"
echo ""
echo "   GitHub does NOT expose 'allow self-approval' via the API."
echo "   You must enable it manually:"
echo ""
echo "   1. Go to: https://github.com/${REPO}/settings/rules"
echo "   2. Click 'New ruleset' → 'New branch ruleset'"
echo "      OR edit the branch protection rule just created at:"
echo "      https://github.com/${REPO}/settings/branches"
echo "   3. Under 'Require a pull request before merging':"
echo "      ✅ Check 'Allow specified actors to bypass required pull requests'"
echo "      → Add yourself as a bypass actor"
echo ""
echo "   Alternatively, since 'enforce_admins' is set to false,"
echo "   as a repo admin you can merge without approvals."
echo ""
echo "🎉 Done!"
