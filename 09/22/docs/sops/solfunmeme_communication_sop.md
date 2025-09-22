# SOP: SOLFUNMEME Communication Protocol

## 1. Purpose:
This Standard Operating Procedure (SOP) outlines the official communication protocol for the SOLFUNMEME project. It defines the primary channels, methods, and principles for interaction within the project's ecosystem, ensuring transparent, decentralized, and verifiable communication.

## 2. Scope:
This SOP applies to all participants, contributors, and stakeholders engaging with the SOLFUNMEME project, including core team members, community members, and AI agents. It covers all formal and verifiable communication related to project development, proposals, and governance.

## 3. Definitions:
*   **SOLFUNMEME Project**: The decentralized, meme-driven ecosystem focused on self-sovereign AI agents and blockchain integration.
*   **Issue**: A formal unit of communication within the Codeberg.org issue tracker, serving as the primary medium for proposals, discussions, bug reports, and tasks.
*   **Wallet Verification**: The cryptographic process of signing a transaction (for free) with a participant's blockchain wallet to verify identity and establish a trustless handshake.
*   **Self-Sovereign Identity**: A decentralized approach to digital identity where individuals have control over their personal data and can verify their identity without relying on central authorities.
*   **SSO Portal**: A Single Sign-On portal, integrated with wallet verification, providing a streamlined and secure access point to project resources and governance mechanisms.

## 4. Responsibilities:
*   **All Participants**: Adhere to the outlined communication channels and procedures.
*   **Core Team/AI Agents**: Monitor and respond to communications within the defined channels, ensuring adherence to the protocol.
*   **System**: Maintain the integrity and accessibility of the Codeberg.org issue tracker and associated verification mechanisms.

## 5. Procedure:

### 5.1. Primary Communication Channel: Codeberg.org Issue Tracker
    a.  **Initiating Communication**: All formal communications, including proposals, questions, bug reports, and task assignments, shall be initiated by opening a new issue on the official Codeberg.org SOLFUNMEME repository: `https://codeberg.org/introspector/SOLFUNMEME/issues/new`.
    b.  **Content**: Issues should be clear, concise, and provide all necessary context for the topic at hand.
    c.  **Response**: Responses and discussions related to an issue shall occur within the comments section of that specific issue.

### 5.2. Identity Verification: Wallet Signature
    a.  **Requirement**: For certain formal interactions (e.g., voting on proposals, submitting significant contributions), participants may be required to verify their identity.
    b.  **Method**: Identity verification shall be performed by signing a transaction (for free) with a participant's blockchain wallet, as outlined in `https://codeberg.org/introspector/SOLFUNMEME/issues/8`.
    c.  **Purpose**: This process establishes a verifiable, self-sovereign identity within the SOLFUNMEME ecosystem, fostering trust and accountability.

### 5.3. Access and Governance: SSO Portal Integration
    a.  **Future Integration**: A Single Sign-On (SSO) portal will be developed to streamline access to project resources and governance mechanisms.
    b.  **Authentication**: The SSO portal will leverage wallet verification for authentication, ensuring secure and decentralized access.
    c.  **Reference**: Further details on the SSO portal development can be found in `https://codeberg.org/introspector/SOLFUNMEME/issues/5`.

## 6. Related Documents:
*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   `solfunmeme_communication_protocol_meme.md` (Conceptual basis for this SOP)
*   `https://codeberg.org/introspector/SOLFUNMEME/issues/new` (Primary communication channel)
*   `https://codeberg.org/introspector/SOLFUNMEME/issues/8` (Wallet verification details)
*   `https://codeberg.org/introspector/SOLFUNMEME/issues/5` (SSO portal development)

## 7. Revision History:
*   2025-09-09: Initial Draft - Derived from `solfunmeme_communication_protocol_meme.md`.