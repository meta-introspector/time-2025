# MEMO: GITHUB-ONLY REFERENCES WITH CRQ BRANCH STRATEGY

**Date**: 2025-01-27  
**Subject**: Mandatory GitHub References with CRQ-Numbered Branches  
**Priority**: CRITICAL - ARCHITECTURE REQUIREMENT  
**Supersedes**: Any previous local path reference policies  

## Core Policy: NO LOCAL REFERENCES ALLOWED

### Universal Rule
- **ALL REFERENCES MUST GO VIA GITHUB** - No exceptions
- **BRANCHES MUST REPRESENT CRQ NUMBERS** - Traceable change requests
- **NO LOCAL REFERENCES ALLOWED** - Path://, file://, or relative paths forbidden
- **GITHUB URLS ONLY** - Ensures reproducibility and auditability

## Implementation Requirements

### Mandatory GitHub URL Format
```nix
# ✅ REQUIRED FORMAT:
nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-XXX-description";

# ❌ FORBIDDEN FORMATS:
src = /local/path/to/repo;                    # Local absolute path
src = ./relative/path;                        # Local relative path  
src = path:/path/to/repo;                     # Path protocol
src = file:///absolute/file/path;             # File protocol
```

### CRQ Branch Naming Convention
```
feature/CRQ-###-short-description
├── CRQ-001-initial-setup
├── CRQ-016-nixify
├── CRQ-025-gemini-integration  
├── CRQ-032-telemetry-logging
└── CRQ-XXX-your-feature
```

**Format Rules:**
- **Prefix**: `feature/CRQ-`
- **Number**: 3-digit zero-padded CRQ number
- **Description**: Kebab-case short description
- **Examples**: `feature/CRQ-027-minimal-qa-test`

## Rationale

### 1. **Reproducibility Guarantee**
- GitHub URLs work identically across all environments
- No dependency on local file system layout
- Version-locked via git commits and refs

### 2. **Auditability & Traceability**  
- Every dependency traceable to specific CRQ
- Complete change history via GitHub
- Branch names encode business requirements

### 3. **Collaboration Safety**
- No "works on my machine" problems
- Team members get identical dependencies  
- CI/CD systems work consistently

### 4. **Security & Compliance**
- No accidental local file leakage
- All sources explicitly declared and versioned
- Full audit trail for compliance requirements

## Implementation Strategy

### Phase 1: Audit Existing References
```bash
# Find all local references (FORBIDDEN)
grep -r "path:/" flake.nix
grep -r "file://" flake.nix  
grep -r "\.\/" flake.nix
grep -r "src = /" flake.nix
```

### Phase 2: Convert to GitHub URLs
```nix
# BEFORE (forbidden):
gemini-cli = {
  url = "path:../../../vendor/external/gemini-cli";
  flake = false;
};

# AFTER (required):
gemini-cli = {
  url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-027-nix-integration";
  flake = false;  
};
```

### Phase 3: Branch Strategy Implementation
1. **Create CRQ branches** for all dependencies
2. **Update flake.nix** files to use GitHub URLs with CRQ refs
3. **Test builds** to ensure everything resolves correctly
4. **Document CRQ mapping** for all active branches

## CRQ Branch Management

### Creating New CRQ Branch
```bash
# 1. Identify next CRQ number
git branch -r | grep "CRQ-" | sort -V | tail -1

# 2. Create descriptive branch
git checkout -b feature/CRQ-028-telemetry-collection

# 3. Update flake references
# Edit flake.nix to use: ?ref=feature/CRQ-028-telemetry-collection

# 4. Commit and push  
git commit -m "CRQ-028: Add telemetry collection capability"
git push origin feature/CRQ-028-telemetry-collection
```

### Updating Dependencies
```nix
# Always specify exact CRQ branch
inputs = {
  nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  
  # When CRQ-027 is merged, create new CRQ for next changes
  gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-027-nix-integration";
  
  # For stable references, use main after CRQ merge
  # gemini-cli.url = "github:meta-introspector/gemini-cli?ref=main";
};
```

## Enforcement Mechanisms

### Pre-commit Hooks
```bash
#!/bin/bash
# Reject any local path references
if grep -r "path:\|file:\|\./\|src = /" *.nix; then
  echo "❌ POLICY VIOLATION: Local references detected"
  echo "All references must use GitHub URLs with CRQ branches"
  exit 1
fi
```

### CI/CD Validation
```yaml
# .github/workflows/validate-references.yml
- name: Validate GitHub-only references
  run: |
    if find . -name "*.nix" -exec grep -l "path:\|file:\|\./\|src = /" {} \; | grep -q .; then
      echo "FAILURE: Local references found"
      exit 1
    fi
```

### Code Review Requirements
- **Mandatory review** for all flake.nix changes
- **Automatic rejection** of local path references
- **CRQ branch verification** before merge

## Exception Process

### NO EXCEPTIONS FOR PRODUCTION
Local references are **NEVER ALLOWED** in:
- Main branch
- Release branches  
- Production deployments
- CI/CD pipelines

### Development-Only Exceptions (Rare)
```nix
# ONLY for local development testing - NEVER commit
# Override in flake.lock for testing:
# nix flake lock --override-input gemini-cli path:./local/test/path
```

**Requirements for dev exceptions:**
1. **Temporary only** - never committed
2. **Documented reason** - why GitHub URL won't work  
3. **Cleanup plan** - timeline to convert to GitHub URL
4. **Team notification** - inform of temporary deviation

## Success Metrics

### Compliance Indicators
- **0 local references** in committed flake.nix files
- **100% CRQ branch usage** for active development
- **All builds reproducible** across environments  
- **Full audit trail** for all dependency changes

### Monthly Audit
- Review all flake.nix files for compliance
- Verify CRQ branch naming consistency
- Check for orphaned local development overrides
- Update CRQ documentation

## Integration with NEVER DELETE Principle

### Additive CRQ Strategy
```
# Build upon existing CRQ branches - never delete
feature/CRQ-016-nixify           # Original nixify work
feature/CRQ-027-minimal-qa       # QA testing framework  
feature/CRQ-028-github-refs      # This policy implementation
feature/CRQ-029-telemetry        # Future telemetry work
```

**Benefits:**
- **Historical preservation** - all CRQ branches maintained
- **Incremental development** - new CRQs build on previous work
- **Rollback capability** - can reference any previous CRQ state
- **Knowledge preservation** - complete development timeline

---

**ENFORCEMENT**: This policy is **MANDATORY** effective immediately. All new flake.nix files must comply. Existing files must be converted within 30 days.

**VIOLATION CONSEQUENCES**: 
- Pre-commit hooks will reject local references
- CI/CD builds will fail with local references  
- Code reviews will automatically reject non-compliant changes

**Signature**: Architecture Team  
**Next Review**: 2025-02-27  
**Policy Version**: 1.0