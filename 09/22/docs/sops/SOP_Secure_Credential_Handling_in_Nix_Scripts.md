# SOP: Secure Credential Handling in Nix Scripts

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the guidelines and procedures for securely handling sensitive credentials (e.g., GitHub Personal Access Tokens, API keys) within Nix-managed scripts and builds. The goal is to ensure that credentials are used without being exposed in insecure ways, maintaining the integrity and security of the project.

## 2. Scope

This SOP applies to all Nix expressions, shell scripts, and build processes within the project that require access to sensitive credentials.

## 3. Principles of Secure Credential Handling

*   **Never hardcode credentials**: Credentials must never be directly written into source code or configuration files that are committed to version control.
*   **Minimize exposure**: Credentials should only be available to the specific processes or commands that require them, and only for the duration necessary.
*   **Use approved mechanisms**: Only use the credential handling mechanisms formally approved and documented in this SOP.
*   **Auditability**: The process should allow for tracking and auditing of credential usage.

## 4. Procedure

**Note**: The detailed procedure for secure credential handling will be added here once a specific solution has been researched, evaluated, and approved through CRQ-019.

Until then, the following general guidelines apply:

*   **Avoid direct environment variable injection for sensitive data in reproducible builds.** If absolutely necessary for temporary debugging or local development, ensure the environment variable is never committed and is cleared immediately after use.
*   **Consult CRQ-019**: Refer to `docs/crqs/CRQ_019_Secure_Credential_Handling_in_Nix_Scripts.md` for the ongoing discussion and proposed solutions for secure credential management.

## 5. Troubleshooting

*   **Authentication failures**: If a script or build fails due to authentication issues, verify that the correct credential handling mechanism is being used and that the necessary credentials have been provided securely.
*   **Credential exposure**: If there is any suspicion of credential exposure, immediately revoke the compromised credential and investigate the cause.

## 6. Related Documents

*   [CRQ-019: Secure Credential Handling in Nix Scripts](docs/crqs/CRQ_019_Secure_Credential_Handling_in_Nix_Scripts.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   `docs/crqs/` (directory for all CRQs)
*   `docs/sops/` (directory for all SOPs)
