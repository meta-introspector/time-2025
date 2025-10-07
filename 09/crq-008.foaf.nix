# crq-008.foaf.nix
{ pkgs, lib, ... }:

let
  mkCRQ = { id, title, problemGoal, proposedSolution, justificationImpact }:
    {
      "@id" = "urn:crq:${id}";
      "@type" = "dcterms:Document"; # Using dcterms:Document
      "dcterms:title" = title;
      "dcterms:description" = problemGoal; # Using dcterms:description for problem/goal
      "schema:solution" = proposedSolution; # Using schema:solution for proposed solution
      "schema:impact" = justificationImpact; # Using schema:impact for justification/impact
      "dcterms:identifier" = id;
      "dcterms:created" = "2025-10-01"; # Placeholder, can be made dynamic
      "dcterms:creator" = { "@id" = "http://github.com/meta-introspector"; }; # Assuming meta-introspector as creator
    };
in
mkCRQ {
  id = "CRQ-008";
  title = "Controlled Side Effects for Agent Operations";
  problemGoal = "While striving for pure functional systems (as outlined in CRQ-001 and CRQ-007), real-world agent operations often necessitate controlled side effects, such as accessing external services or securely managing credentials. Uncontrolled side effects can compromise reproducibility, security, and verifiability. Goal: To establish a secure, auditable, and reproducible framework for managing necessary side effects within agent operations, specifically focusing on secure credential management via a vault and controlled external communication via HTTPS URL access for single-step agent actions.";
  proposedSolution = "1.  **Secure Vault Integration:** Integrate a secure vault solution (e.g., HashiCorp Vault, AWS Secrets Manager, or a Nix-based secrets management system) for storing and retrieving sensitive information required by agents (e.g., API keys, authentication tokens, private keys). Access to the vault will be strictly controlled, auditable, and integrated into the Nix environment to ensure reproducible access patterns. 2.  **Controlled HTTPS URL Access:** Implement a controlled mechanism for agents to perform single-step external network requests via HTTPS URLs. This mechanism will ensure that all external communications are explicitly declared, logged, and potentially sandboxed to limit their impact on the system's purity and reproducibility. Each external call will be treated as a distinct, auditable side effect. 3.  **Nix-Managed Side Effect Declarations:** Utilize Nix to declare and manage the dependencies and configurations for both vault access and HTTPS communication. This will ensure that the environment for executing side effects is reproducible and that all external interactions are explicitly defined within the Nix build. 4.  **Agent Step Isolation:** Design agent operations such that each step requiring a side effect (e.g., fetching a secret from the vault, making an API call) is isolated and clearly demarcated. This isolation facilitates testing, auditing, and understanding the impact of each side effect. 5.  **Auditable Side Effect Logs:** Implement comprehensive logging for all vault accesses and HTTPS communications, capturing details such as timestamps, agent identity, accessed resources, and data exchanged (where appropriate and secure). These logs will be integrated into the overall reproducible analysis pipeline (CRQ-001) for auditing and verification.";
  justificationImpact = "**Enhanced Security:** Centralized and controlled management of secrets via a vault significantly reduce the risk of credential exposure. **Reproducible Side Effects:** By explicitly declaring and managing side effects within Nix, the impact on reproducibility is minimized, allowing for more deterministic agent behavior. **Improved Auditability:** Detailed logging of all external interactions provides a clear audit trail for compliance, security analysis, and debugging. **Clearer Agent Logic:** Isolating side effects makes agent code easier to understand, test, and maintain, as the boundaries between pure and impure operations are well-defined. **Scalability and Maintainability:** A standardized approach to side effect management simplifies the development and deployment of complex agents. **Compliance:** Facilitates adherence to security and data privacy regulations by providing controlled and auditable access to sensitive resources.";
}
