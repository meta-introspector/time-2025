# MEMO: NEVER DELETE - PLAN FOR PERMANENCE

**Date**: 2025-01-27  
**Subject**: Architectural Principles for Sustainable Development  
**Priority**: CRITICAL  

## Core Principle: NEVER DELETE

### Universal Rule
- **NEVER DELETE** existing files, directories, or data structures
- **PLAN FOR PERMANENCE** - All additions must be designed to coexist with existing systems
- **MONOTONIC OPERATIONS** - Only additive changes allowed
- **ADDITIVE ARCHITECTURE** - Build upon, never replace
- **MONADIC COMPOSITION** - Chain operations without side effects on existing state

## Implementation Guidelines

### File System Operations
```
✅ ALLOWED:
- mkdir -p (create directories)
- touch (create new files) 
- echo >> (append to files)
- cp source new_destination (copy to new location)
- ln -s (create symlinks)

❌ FORBIDDEN:
- rm, rmdir (deletion)
- mv (moving/renaming - implies deletion of original)
- > (overwrite redirection)
- truncate operations
```

### Version Control Patterns
```
✅ ADDITIVE:
- New commits (monotonic history)
- New branches (parallel development)
- New tags (immutable markers)
- New files in new paths

❌ DESTRUCTIVE:
- Force pushes (rewrites history)
- Branch deletion
- File removal from tracking
- History modification
```

### Nix Architecture Patterns
```
✅ MONADIC COMPOSITION:
- New flakes in new directories
- Additional inputs to existing flakes
- Overlay compositions
- Derivative packages extending base packages

❌ REPLACEMENT:
- Overriding existing flakes in-place  
- Removing inputs from flakes
- Breaking existing derivation outputs
```

## Practical Applications

### Directory Structure Evolution
```
project/
├── v1/           # Never delete - permanent archive
├── v2/           # Additive improvement on v1
├── experimental/ # New explorations - never replace v1/v2
└── current/      # Symlink to latest stable (changeable pointer)
```

### Configuration Management
```
config/
├── base.nix         # Original configuration - permanent
├── base-v2.nix      # Enhanced version - additive
├── overrides/       # Additional configurations
│   ├── feature-a.nix
│   └── feature-b.nix
└── composed.nix     # Monadic composition of all parts
```

### Test Development
```
tests/
├── 2025-01-27-hello-world/    # Today's test - permanent
├── 2025-01-27-integration/     # Additional test - coexists  
├── 2025-01-28-regression/      # Future test - builds upon
└── archived/                   # Historical tests - never deleted
    └── 2025-01-26-prototype/   # Previous work - preserved
```

## Benefits of This Approach

### 1. **Historical Preservation**
- Complete audit trail of all decisions
- Ability to understand evolution of thought
- Rollback capability without data loss

### 2. **Reduced Risk**
- No accidental data loss
- No breaking of dependent systems
- Safe experimentation environment

### 3. **Incremental Development**
- Build confidence through small additions
- Test new ideas alongside stable systems
- Gradual migration paths

### 4. **Collaborative Safety**
- Multiple developers can work without conflicts
- No fear of destroying others' work
- Clear ownership of additive contributions

## Implementation Strategy

### Phase 1: Establish Patterns
1. Create new directories for new features
2. Use timestamped naming for experiments  
3. Implement symlink patterns for "current" pointers
4. Document additive composition patterns

### Phase 2: Tool Integration
1. Develop scripts that only create, never delete
2. Implement guards against destructive operations
3. Create composition utilities for monadic building
4. Establish automated archival processes

### Phase 3: Cultural Adoption
1. Train team on additive-only workflows
2. Establish code review patterns for permanence
3. Create templates for additive development
4. Document success stories and lessons learned

## Emergency Exceptions

**ONLY** in case of:
- Legal compliance requirements (data must be destroyed)
- Security breaches (compromised credentials)
- Storage limitations (with explicit archival process)

**Process for exceptions:**
1. Document the necessity with timestamps and reasoning
2. Create complete backup/archive before any removal
3. Use minimal scope - remove only what is absolutely necessary
4. Update this memo with lessons learned

## Monitoring and Enforcement

### Automated Checks
- Pre-commit hooks preventing destructive operations
- CI/CD validation of additive-only changes
- Regular audits of repository growth patterns

### Manual Reviews  
- All changes reviewed for adherence to additive principles
- Monthly assessment of directory structure health
- Quarterly review of this memo and its effectiveness

---

**Remember**: Every deletion is a loss of knowledge. Every addition is an investment in understanding. Build systems that grow stronger over time through accumulation of wisdom, not replacement of ideas.

**Signature**: Development Team  
**Next Review**: 2025-02-27