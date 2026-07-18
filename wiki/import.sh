#!/usr/bin/env bash
# Imports all Aurefold content (pages + images) into the running wiki.
# Run AFTER the install wizard + LocalSettings are in place:
#   ./import.sh [admin-username]      (default: Admin)
set -euo pipefail
ADMIN="${1:-Admin}"

# sitewide CSS needs the interface-admin right
docker compose exec -T mediawiki php maintenance/run.php createAndPromote --force --sysop --bureaucrat --custom-groups interface-admin "$ADMIN" >/dev/null 2>&1 || true

echo "== Importing images =="
docker compose exec -T mediawiki php maintenance/run.php importImages \
  --user="$ADMIN" --comment="Aurefold canon assets" --overwrite /opt/aurefold/images || true

echo "== Importing pages =="
# manifest.tsv: <page title> TAB <path inside container>
while IFS=$'\t' read -r title path <&3; do
  [ -z "$title" ] && continue
  echo "  -> $title"
  docker compose exec -T mediawiki sh -c \
    "php maintenance/run.php edit --user='$ADMIN' --summary='Aurefold content import' \"\$0\" < '$path'" "$title" </dev/null >/dev/null
done 3< content/manifest.tsv

echo "== Rebuilding =="
docker compose exec -T mediawiki php maintenance/run.php rebuildrecentchanges >/dev/null
docker compose restart mediawiki >/dev/null 2>&1 || true
echo "Done. Visit your wiki and hard-refresh (Ctrl+Shift+R) to load the theme."
