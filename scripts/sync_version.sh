#!/usr/bin/env bash
#
# sync_version.sh - Sync version number across all project files
# This script ensures version consistency across ipcheck, setup.sh, README.md, man page, and menu files
# Usage: ./scripts/sync_version.sh
#

set -euo pipefail

# Get version from ipcheck (source of truth)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IPCHECK_SCRIPT="$PROJECT_ROOT/ipcheck"

if [[ ! -f "$IPCHECK_SCRIPT" ]]; then
    echo "Error: ipcheck script not found at $IPCHECK_SCRIPT" >&2
    exit 1
fi

# Extract version from ipcheck script
VERSION=$(grep -E "^IPCHECK_VERSION=" "$IPCHECK_SCRIPT" 2>/dev/null | head -1 | cut -d'"' -f2)

if [[ -z "$VERSION" ]]; then
    echo "Error: Could not extract version from ipcheck script" >&2
    exit 1
fi

echo "Syncing version $VERSION across all project files..."
echo ""

# Update setup.sh
if [[ -f "$PROJECT_ROOT/setup.sh" ]]; then
    # Update IPCHECK_SUITE_VERSION variable
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS uses BSD sed
        sed -i '' "s/^IPCHECK_SUITE_VERSION=\"[^\"]*\"/IPCHECK_SUITE_VERSION=\"$VERSION\"/" "$PROJECT_ROOT/setup.sh"
    else
        # Linux uses GNU sed
        sed -i "s/^IPCHECK_SUITE_VERSION=\"[^\"]*\"/IPCHECK_SUITE_VERSION=\"$VERSION\"/" "$PROJECT_ROOT/setup.sh"
    fi
    echo "  ✓ Updated setup.sh (IPCHECK_SUITE_VERSION=$VERSION)"
fi

# Update README.md
if [[ -f "$PROJECT_ROOT/README.md" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/^# IPCheck Suite v[0-9.]*/# IPCheck Suite v$VERSION/" "$PROJECT_ROOT/README.md"
    else
        sed -i "s/^# IPCheck Suite v[0-9.]*/# IPCheck Suite v$VERSION/" "$PROJECT_ROOT/README.md"
    fi
    echo "  ✓ Updated README.md"
fi

# Update man page
if [[ -f "$PROJECT_ROOT/man/ipcheck.1" ]]; then
    current_date=$(date +"%B %Y")
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/\\.TH IPCHECK 1 \"[^\"]*\" \"v[0-9.]*\" \".*\"/.TH IPCHECK 1 \"$current_date\" \"v$VERSION\" \"IP Reputation Tool\"/" "$PROJECT_ROOT/man/ipcheck.1"
    else
        sed -i "s/\\.TH IPCHECK 1 \"[^\"]*\" \"v[0-9.]*\" \".*\"/.TH IPCHECK 1 \"$current_date\" \"v$VERSION\" \"IP Reputation Tool\"/" "$PROJECT_ROOT/man/ipcheck.1"
    fi
    echo "  ✓ Updated man/ipcheck.1"
fi

# Update menu_main.sh
if [[ -f "$PROJECT_ROOT/lib/menu_main.sh" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/v\\\${IPCHECK_VERSION:-[0-9.]*}/v\\\${IPCHECK_VERSION:-$VERSION}/" "$PROJECT_ROOT/lib/menu_main.sh"
    else
        sed -i "s/v\\\${IPCHECK_VERSION:-[0-9.]*}/v\\\${IPCHECK_VERSION:-$VERSION}/" "$PROJECT_ROOT/lib/menu_main.sh"
    fi
    echo "  ✓ Updated lib/menu_main.sh"
fi

# Update ipcheck header comment
if [[ -f "$IPCHECK_SCRIPT" ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/# ipcheck - Advanced, parallel IP reputation checker v[0-9.]*/# ipcheck - Advanced, parallel IP reputation checker v$VERSION/" "$IPCHECK_SCRIPT"
    else
        sed -i "s/# ipcheck - Advanced, parallel IP reputation checker v[0-9.]*/# ipcheck - Advanced, parallel IP reputation checker v$VERSION/" "$IPCHECK_SCRIPT"
    fi
    echo "  ✓ Updated ipcheck header comment"
fi

echo ""
echo "✓ Version sync complete! All files now use version $VERSION"
echo ""
echo "Files updated:"
echo "  - ipcheck (source of truth: IPCHECK_VERSION=$VERSION)"
echo "  - setup.sh (IPCHECK_SUITE_VERSION=$VERSION)"
echo "  - README.md"
echo "  - man/ipcheck.1"
echo "  - lib/menu_main.sh"
echo ""
echo "Note: The installer (setup.sh) will automatically sync its version"
echo "      from the ipcheck script during installation to ensure consistency."
