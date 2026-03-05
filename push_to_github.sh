#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# One-time script to publish the report to GitHub and enable GitHub Pages.
# Run this once from your Terminal inside this folder:
#   cd "path/to/report-html"
#   bash push_to_github.sh
# ─────────────────────────────────────────────────────────────────────────────

TOKEN="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"
REPO_NAME="Reporte-UNESCO-CA-Car"
USERNAME=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user | python3 -c "import sys,json; print(json.load(sys.stdin)['login'])")

echo "👤 GitHub user: $USERNAME"
echo "📦 Creating repo: $REPO_NAME ..."

# Create the public repo
curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  https://api.github.com/user/repos \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"La Regulación de Plataformas Digitales en México, Centroamérica y el Caribe — UNESCO/EU 2026\",
    \"private\": false,
    \"auto_init\": false
  }" | python3 -c "import sys,json; d=json.load(sys.stdin); print('✅ Repo created:', d.get('html_url', d.get('message','error')))"

echo ""
echo "🚀 Pushing files ..."

# Fix the branch name and push
git branch -m master main 2>/dev/null || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://$USERNAME:$TOKEN@github.com/$USERNAME/$REPO_NAME.git"
git push -u origin main

echo ""
echo "⚙️  Enabling GitHub Pages ..."
curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/$USERNAME/$REPO_NAME/pages" \
  -d '{"source": {"branch": "main", "path": "/"}}' | python3 -c "
import sys, json
d = json.load(sys.stdin)
url = d.get('html_url', '')
if url:
    print(f'✅ GitHub Pages enabled!')
    print(f'🌐 Your site will be live at: {url}')
    print('   (may take 1–2 minutes to deploy)')
else:
    print('ℹ️  Pages response:', d.get('message', d))
"

echo ""
echo "Done! Repo: https://github.com/$USERNAME/$REPO_NAME"
