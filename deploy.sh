#!/bin/bash
set -e

echo "Deploying Global User Profile..."
cp ./GEMINI.md ~/.gemini/GEMINI.md
echo "✅ GEMINI.md deployed."

echo ""
echo "Installing Plugins globally..."
agy plugin install ./core-engineering
agy plugin install ./gcp-data-eng
agy plugin install ./ui-engineering
echo "✅ Plugins installed globally in ~/.gemini/config/plugins/"

echo ""
echo "Configuring Antigravity CLI to auto-discover global plugins..."

# The CLI auto-discovers skills and agents placed in ~/.gemini/antigravity-cli/
# But 'agy plugin install' places them in ~/.gemini/config/plugins/ so they are shared across the system (e.g. IDEs).
# We bridge them by explicitly registering their paths in the CLI's configuration directory.

cat << 'EOF' > ~/.gemini/antigravity-cli/skills.json
{
  "entries": [
    { "path": "/usr/local/google/home/antoniopaulino/.gemini/config/plugins/core-engineering/skills" },
    { "path": "/usr/local/google/home/antoniopaulino/.gemini/config/plugins/gcp-data-eng/skills" },
    { "path": "/usr/local/google/home/antoniopaulino/.gemini/config/plugins/ui-engineering/skills" }
  ]
}
EOF
echo "✅ skills.json configured in ~/.gemini/antigravity-cli/"

cat << 'EOF' > ~/.gemini/antigravity-cli/agents.json
{
  "entries": [
    { "path": "/usr/local/google/home/antoniopaulino/.gemini/config/plugins/gcp-data-eng/agents" },
    { "path": "/usr/local/google/home/antoniopaulino/.gemini/config/plugins/ui-engineering/agents" }
  ]
}
EOF
echo "✅ agents.json configured in ~/.gemini/antigravity-cli/"

echo ""
echo "🎉 Deployment complete! Your skills and agents are now fully connected."
echo "You can verify them by running: agy --print \"/skills\" and agy --print \"/agents\""
