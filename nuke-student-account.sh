#!/usr/bin/env bash
#
# AWS Nuke - clean the AWSDevOpsClass student account.
# Runs a REAL deletion (no dry-run). The account itself is NOT closed
# or removed from AWS Organizations.
#
# Run from Git Bash on Windows, or another Bash shell with AWS CLI configured.
# For the Windows installation used in this workflow, the script detects:
#   /c/awscleanup/aws-nuke.exe
#
set -Eeuo pipefail

# ---------------------------------------------------------------------------
# FIXED SAFETY BOUNDARIES - change only when intentionally targeting another
# member account. Never set TARGET_ACCOUNT_ID to the Organizations management
# account.
# ---------------------------------------------------------------------------
TARGET_ACCOUNT_ID="325657596892"
MANAGEMENT_ACCOUNT_ID="408949636936"
TARGET_ALIAS="awsdevopsclass-cleanup-325657596892"

# Resolve AWS Nuke executable.
if command -v aws-nuke >/dev/null 2>&1; then
    AWS_NUKE_BIN="$(command -v aws-nuke)"
elif [[ -x "/c/awscleanup/aws-nuke.exe" ]]; then
    AWS_NUKE_BIN="/c/awscleanup/aws-nuke.exe"
elif [[ -x "/mnt/c/awscleanup/aws-nuke.exe" ]]; then
    AWS_NUKE_BIN="/mnt/c/awscleanup/aws-nuke.exe"
else
    echo "ERROR: aws-nuke was not found."
    echo "Install it or set AWS_NUKE_BIN to its executable path."
    exit 1
fi

command -v aws >/dev/null 2>&1 || {
    echo "ERROR: AWS CLI was not found in this Bash environment."
    exit 1
}

echo "Checking AWS credentials and caller identity..."
CALLER_ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"

if [[ "$CALLER_ACCOUNT" != "$TARGET_ACCOUNT_ID" ]]; then
    echo "SAFETY STOP: credentials resolve to account $CALLER_ACCOUNT."
    echo "Expected target account: $TARGET_ACCOUNT_ID"
    echo "No deletion was started."
    exit 1
fi

if [[ "$CALLER_ACCOUNT" == "$MANAGEMENT_ACCOUNT_ID" ]]; then
    echo "SAFETY STOP: management account credentials detected."
    exit 1
fi

echo "Verified target account: $CALLER_ACCOUNT"

# Ensure the expected account alias exists. If the account already has a
# different alias, stop rather than silently changing it.
CURRENT_ALIAS="$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)"
if [[ "$CURRENT_ALIAS" == "None" || -z "$CURRENT_ALIAS" ]]; then
    echo "Creating account alias: $TARGET_ALIAS"
    aws iam create-account-alias --account-alias "$TARGET_ALIAS"
    CURRENT_ALIAS="$TARGET_ALIAS"
fi

if [[ "$CURRENT_ALIAS" != "$TARGET_ALIAS" ]]; then
    echo "SAFETY STOP: account alias is '$CURRENT_ALIAS'."
    echo "Expected alias: '$TARGET_ALIAS'."
    echo "No deletion was started."
    exit 1
fi

# Keep the configuration beside this script so it is easy to inspect.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/aws-nuke-config.yaml"

cat > "$CONFIG_FILE" <<YAML
regions:
  - all

blocklist:
  - "$MANAGEMENT_ACCOUNT_ID"

blocklist-terms:
  - "prod"
  - "production"
  - "live"

accounts:
  "$TARGET_ACCOUNT_ID": {}
YAML

echo
echo "AWS Nuke executable: $AWS_NUKE_BIN"
"$AWS_NUKE_BIN" version
echo
echo "Configuration written to: $CONFIG_FILE"
echo "Target account:           $TARGET_ACCOUNT_ID"
echo "Target alias:             $TARGET_ALIAS"
echo "Management blocklist:     $MANAGEMENT_ACCOUNT_ID"
echo
echo "WARNING: This is a REAL deletion. There is NO dry-run."
echo "Supported resources in the target account may be permanently deleted"
echo "across all enabled regions and global resource scopes."
echo "The AWS account itself will remain open and in the Organization."
echo

read -r -p "To proceed, type the target account ID ($TARGET_ACCOUNT_ID): " CONFIRM
if [[ "$CONFIRM" != "$TARGET_ACCOUNT_ID" ]]; then
    echo "Confirmation did not match. No deletion was started."
    exit 1
fi

echo
echo "Starting AWS Nuke. It will request its own account-alias confirmation."
echo "When prompted by AWS Nuke, enter exactly:"
echo "$TARGET_ALIAS"
echo

"$AWS_NUKE_BIN" run --config "$CONFIG_FILE" --no-dry-run

echo
echo "AWS Nuke process completed. Review the output above for failures or"
echo "resources that could not be removed. This does not prove every AWS"
echo "resource or service commitment has been removed."
