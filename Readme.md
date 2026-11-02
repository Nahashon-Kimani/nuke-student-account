# Nuke Morning School Account

This project contains `nuke-student-account.sh`, a script intended to remove a student account. Account removal may revoke access or permanently delete data. Use it only with authorization on systems you administer.

> **Review required:** The script was not provided with this request, so its commands, supported platforms, arguments, and effects have not been verified. Inspect the script before use; do not assume it preserves files or only disables an account.

## Before implementation or use

1. Read the script and identify every account, group, session, and file operation.
2. Confirm its supported operating system, dependencies, privilege requirements, and exact argument syntax from its source or documentation. Never guess a command or option.
3. Verify the student identifier and obtain the approvals required by school policy.
4. Back up or export records that must be retained.
5. Test in a disposable environment using a test account, not a real student account.

## Safe operating procedure

- Prefer a dry-run that displays the target and proposed changes without modifying anything. Do not use the script operationally until this and other safety checks have been tested.
- Ensure it validates the identifier, rejects empty or ambiguous targets, and refuses protected/system accounts.
- Review the dry-run output and obtain explicit approval before any irreversible action.
- Run only on a supported system using the documented invocation.

To inspect the script without running it:

```bash
less nuke-student-account.sh
```

Use a help option only if the script documents one. This README does not provide a run command because the script's interface has not been reviewed.

## After execution

- Check the exit status and logs for errors.
- Verify the intended account was affected and unrelated accounts remain unchanged.
- Record the approval, target identifier, operator, time, and outcome according to school policy.
- Follow the school's recovery and retention procedures if data was removed unexpectedly.

## Readiness checklist

Document the supported platforms, exact usage, effects, and recovery limitations. Before operational use, verify that the script validates inputs, protects system accounts, supports a dry-run, requires confirmation for destructive actions, handles failures safely, and avoids logging credentials or unnecessary student data.
