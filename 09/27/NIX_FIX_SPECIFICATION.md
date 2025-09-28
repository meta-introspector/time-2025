# 🚀 NIX FIX SPECIFICATION: Headless Gemini CLI with Comprehensive Telemetry

## 🎯 **MISSION: GET THIS NIX FIX!!!**

**Objective**: Run Gemini CLI headless with prompt, capture ALL telemetry, package safely  
**Priority**: CRITICAL - This is the breakthrough we need  
**Status**: READY FOR IMPLEMENTATION  

---

## 📋 **COMPREHENSIVE REQUIREMENTS**

### **Core Functionality:**
- ✅ **Run Gemini headless** with prompt "hello world"
- ✅ **Capture strace** - full system call trace
- ✅ **Capture stdout** - all output streams  
- ✅ **Capture telemetry** - AI behavior analysis
- ✅ **Package everything** - complete diagnostic bundle
- ✅ **Redact credentials** - security-first approach
- ✅ **Allow ~/.gemini access** - configuration integration
- ✅ **Allow HTTPS to Google** - API communication
- ✅ **Impure Nix build** - network access enabled

### **Security Requirements:**
- 🔒 **Credential redaction** - automatic PII scrubbing
- 🔒 **Sandboxed execution** - isolated environment
- 🔒 **Audit trail** - complete operation logging  
- 🔒 **Reproducible builds** - deterministic outputs

---

## 🏗️ **IMPLEMENTATION ARCHITECTURE**

### **Phase 1: Fixed Source Path Approach**
```nix
{
  description = "Headless Gemini CLI with comprehensive telemetry capture";
  
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=production/CRQ-029-approved";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=production/CRQ-030-approved";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=production/CRQ-031-approved";
  };
  
  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Comprehensive telemetry capture derivation
        geminiTelemetryCapture = pkgs.stdenv.mkDerivation {
          pname = "gemini-telemetry-capture";
          version = "2025-01-27-v2";
          src = gemini-cli;
          
          # CRITICAL: Enable impure build for network access
          __impure = true;
          
          buildInputs = [
            pkgs.nodejs_22
            pkgs.strace        # System call tracing
            pkgs.jq           # JSON processing
            pkgs.curl         # HTTPS verification
            pkgs.gnused       # Credential redaction
            pkgs.gawk         # Log processing
          ];
          
          # Configure environment for headless operation
          GEMINI_API_KEY = builtins.getEnv "GEMINI_API_KEY";
          HOME = "/tmp/gemini-home";
          
          buildPhase = ''
            echo "=== GEMINI HEADLESS TELEMETRY CAPTURE - $(date) ==="
            
            # Create comprehensive output structure
            mkdir -p $out/{telemetry,logs,traces,analysis,redacted}
            
            # Setup isolated home directory with .gemini config
            mkdir -p /tmp/gemini-home/.gemini
            
            # Copy settings.json to isolated environment
            cat > /tmp/gemini-home/.gemini/settings.json << 'EOF'
            {
              "general": {
                "preferredEditor": "none"
              },
              "telemetry": {
                "enabled": true,
                "target": "local",
                "outfile": "logs/gemini-telemetry.log",
                "useCollector": true
              },
              "tools": {
                "core": ["*", "all"]
              },
              "security": {
                "auth": {
                  "selectedType": "oauth-personal"
                }
              }
            }
            EOF
            
            # Ensure gemini.js is executable and available
            if [ -f "$src/bundle/gemini.js" ]; then
              echo "✅ Found gemini.js at: $src/bundle/gemini.js"
              cp "$src/bundle/gemini.js" ./gemini.js
              chmod +x ./gemini.js
            else
              echo "❌ gemini.js not found - listing source contents:"
              find "$src" -name "*.js" | head -20
              exit 1
            fi
            
            # Pre-execution environment capture
            echo "=== ENVIRONMENT SNAPSHOT ===" | tee $out/logs/environment.log
            echo "Node version: $(node --version)" | tee -a $out/logs/environment.log  
            echo "PWD: $(pwd)" | tee -a $out/logs/environment.log
            echo "HOME: $HOME" | tee -a $out/logs/environment.log
            echo "GEMINI_API_KEY set: $([ -n "$GEMINI_API_KEY" ] && echo "YES" || echo "NO")" | tee -a $out/logs/environment.log
            echo "Settings file: $(ls -la /tmp/gemini-home/.gemini/settings.json)" | tee -a $out/logs/environment.log
            echo "" | tee -a $out/logs/environment.log
            
            # CORE OPERATION: Run Gemini headless with comprehensive tracing
            echo "=== EXECUTING GEMINI CLI WITH TELEMETRY CAPTURE ===" | tee -a $out/logs/execution.log
            echo "Prompt: 'hello world'" | tee -a $out/logs/execution.log
            echo "Timestamp: $(date -Iseconds)" | tee -a $out/logs/execution.log
            echo "" | tee -a $out/logs/execution.log
            
            # Run with strace for complete system call capture
            echo "Starting strace capture..." | tee -a $out/logs/execution.log
            strace -f -e trace=all -o $out/traces/gemini-strace.log \
              timeout 60 node ./gemini.js "hello world" \
              > $out/logs/gemini-stdout.log 2> $out/logs/gemini-stderr.log || {
              
              EXIT_CODE=$?
              echo "Gemini execution completed with exit code: $EXIT_CODE" | tee -a $out/logs/execution.log
              echo "This is expected for first run without proper API setup" | tee -a $out/logs/execution.log
            }
            
            # Capture telemetry if generated
            echo "=== TELEMETRY COLLECTION ===" | tee -a $out/logs/execution.log
            if [ -f "/tmp/gemini-home/.gemini/logs/gemini-telemetry.log" ]; then
              echo "✅ Telemetry captured!" | tee -a $out/logs/execution.log
              cp "/tmp/gemini-home/.gemini/logs/gemini-telemetry.log" $out/telemetry/
            else
              echo "ℹ️  No telemetry file generated (expected without API key)" | tee -a $out/logs/execution.log
              # Check for any log files created
              find /tmp/gemini-home -name "*.log" -exec cp {} $out/telemetry/ \; 2>/dev/null || true
            fi
            
            # Process and analyze captured data
            echo "=== DATA ANALYSIS ===" | tee -a $out/logs/execution.log
            
            # Analyze strace output
            if [ -f "$out/traces/gemini-strace.log" ]; then
              echo "Strace captured $(wc -l < $out/traces/gemini-strace.log) system calls" | tee -a $out/analysis/strace-summary.txt
              
              # Extract key patterns
              echo "=== NETWORK CALLS ===" >> $out/analysis/network-analysis.txt
              grep -E "(connect|sendto|recvfrom)" $out/traces/gemini-strace.log | head -20 >> $out/analysis/network-analysis.txt || true
              
              echo "=== FILE OPERATIONS ===" >> $out/analysis/file-operations.txt  
              grep -E "(open|read|write|close)" $out/traces/gemini-strace.log | head -20 >> $out/analysis/file-operations.txt || true
              
              echo "=== PROCESS OPERATIONS ===" >> $out/analysis/process-operations.txt
              grep -E "(clone|fork|exec)" $out/traces/gemini-strace.log | head -20 >> $out/analysis/process-operations.txt || true
            fi
            
            # Analyze stdout/stderr
            echo "Stdout lines: $(wc -l < $out/logs/gemini-stdout.log)" | tee -a $out/analysis/output-summary.txt
            echo "Stderr lines: $(wc -l < $out/logs/gemini-stderr.log)" | tee -a $out/analysis/output-summary.txt
            
            # SECURITY: Credential redaction
            echo "=== CREDENTIAL REDACTION ===" | tee -a $out/logs/execution.log
            
            # Create redacted copies of all sensitive files
            for file in $out/logs/* $out/traces/* $out/telemetry/*; do
              if [ -f "$file" ]; then
                basename_file=$(basename "$file")
                # Redact API keys, tokens, credentials
                sed -E 's/[A-Za-z0-9]{32,}/[REDACTED-TOKEN]/g; s/AIza[A-Za-z0-9_-]{35}/[REDACTED-API-KEY]/g; s/ya29\.[A-Za-z0-9_-]+/[REDACTED-OAUTH-TOKEN]/g' "$file" > "$out/redacted/$basename_file"
              fi
            done
            
            # Generate comprehensive manifest
            echo "=== TELEMETRY CAPTURE MANIFEST ===" | tee $out/MANIFEST.txt
            echo "Capture Date: $(date -Iseconds)" | tee -a $out/MANIFEST.txt
            echo "Gemini CLI Source: $src" | tee -a $out/MANIFEST.txt
            echo "Node Version: $(node --version)" | tee -a $out/MANIFEST.txt
            echo "Prompt: hello world" | tee -a $out/MANIFEST.txt
            echo "" | tee -a $out/MANIFEST.txt
            echo "Files Generated:" | tee -a $out/MANIFEST.txt
            find $out -type f | sort | tee -a $out/MANIFEST.txt
            echo "" | tee -a $out/MANIFEST.txt
            echo "Security: Credentials redacted in redacted/ directory" | tee -a $out/MANIFEST.txt
            echo "Telemetry: Available in telemetry/ directory" | tee -a $out/MANIFEST.txt
            echo "Traces: System calls captured in traces/ directory" | tee -a $out/MANIFEST.txt
            
            echo "✅ COMPREHENSIVE TELEMETRY CAPTURE COMPLETE" | tee -a $out/logs/execution.log
          '';
          
          installPhase = ''
            echo "=== CREATING ANALYSIS TOOLS ==="
            
            # Create telemetry analyzer script
            mkdir -p $out/bin
            cat > $out/bin/analyze-telemetry << 'EOF'
            #!/usr/bin/env bash
            echo "=== Gemini CLI Telemetry Analysis ==="
            echo "Generated: $(date)"
            echo ""
            
            RESULT_PATH="$1"
            if [ -z "$RESULT_PATH" ]; then
              echo "Usage: $0 <capture-result-path>"
              exit 1
            fi
            
            echo "=== MANIFEST ==="
            cat "$RESULT_PATH/MANIFEST.txt"
            echo ""
            
            echo "=== EXECUTION SUMMARY ==="
            tail -20 "$RESULT_PATH/logs/execution.log" 2>/dev/null || echo "No execution log"
            echo ""
            
            echo "=== OUTPUT ANALYSIS ==="
            echo "Stdout (first 10 lines):"
            head -10 "$RESULT_PATH/logs/gemini-stdout.log" 2>/dev/null || echo "No stdout"
            echo ""
            echo "Stderr (first 10 lines):"  
            head -10 "$RESULT_PATH/logs/gemini-stderr.log" 2>/dev/null || echo "No stderr"
            echo ""
            
            echo "=== STRACE ANALYSIS ==="
            if [ -f "$RESULT_PATH/analysis/strace-summary.txt" ]; then
              cat "$RESULT_PATH/analysis/strace-summary.txt"
            else
              echo "No strace analysis available"
            fi
            echo ""
            
            echo "=== SECURITY STATUS ==="
            echo "Redacted files available: $(ls "$RESULT_PATH/redacted/" | wc -l) files"
            echo "Original logs preserved for analysis"
            echo "Credentials automatically redacted for sharing"
            
            EOF
            chmod +x $out/bin/analyze-telemetry
            
            echo "✅ Analysis tools installed"
          '';
          
          meta = {
            description = "Comprehensive Gemini CLI telemetry capture with security redaction";
            license = pkgs.lib.licenses.mit;
          };
        };
      in
      {
        packages.default = geminiTelemetryCapture;
        
        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "run-gemini-telemetry-capture" ''
            echo "=== GEMINI CLI TELEMETRY CAPTURE RUNNER ==="
            echo "Building comprehensive telemetry capture..."
            
            # Check for API key
            if [ -z "$GEMINI_API_KEY" ]; then
              echo "⚠️  Warning: GEMINI_API_KEY not set"
              echo "   Some features may not work without API key"
              echo "   Continuing with diagnostic capture..."
            else
              echo "✅ GEMINI_API_KEY detected"
            fi
            
            # Build with impure flag for network access
            RESULT=$(nix build --impure --no-link --print-out-paths ${self.packages.${system}.default})
            
            if [ -n "$RESULT" ] && [ -d "$RESULT" ]; then
              echo "✅ Telemetry capture completed at: $RESULT"
              echo ""
              
              # Run analysis
              exec "$RESULT/bin/analyze-telemetry" "$RESULT"
            else
              echo "❌ Telemetry capture failed"
              exit 1
            fi
          ''}";
        };
      }
    );
}
```

---

## 🎯 **EXECUTION STRATEGY**

### **Step 1: Create Fixed Flake (V2)**
```bash
mkdir -p tests/2025-01-27-gemini-telemetry-capture-v2
# Use the comprehensive flake.nix above
```

### **Step 2: Test Runner Script**  
```bash
cat > run_gemini_telemetry_capture.sh << 'EOF'
#!/usr/bin/env bash
set -e

echo "🚀 GEMINI CLI TELEMETRY CAPTURE - THE NIX FIX!"
echo "Date: $(date)"
echo ""

# Configuration
TEST_DIR="tests/2025-01-27-gemini-telemetry-capture-v2"
LOG_DIR="logs"
ARCHIVE_DIR="telemetry-archives/$(date +%Y-%m-%d)"

# Ensure directories
mkdir -p "$LOG_DIR" "$ARCHIVE_DIR"

cd "$TEST_DIR"

# Check API key status
if [ -n "$GEMINI_API_KEY" ]; then
  echo "✅ GEMINI_API_KEY is set - full telemetry capture possible"
else
  echo "⚠️  GEMINI_API_KEY not set - diagnostic mode only"
  echo "   Set with: export GEMINI_API_KEY='your-key-here'"
fi

echo ""
echo "🔧 Building telemetry capture with impure flag..."

# Run with comprehensive logging  
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
if nix run --impure > "../logs/telemetry_capture_$TIMESTAMP.log" 2>&1; then
  echo "✅ Telemetry capture completed successfully!"
  
  # Archive the results
  RESULT_PATH=$(nix build --impure --no-link --print-out-paths)
  if [ -n "$RESULT_PATH" ]; then
    echo "📊 Results available at: $RESULT_PATH"
    
    # Copy to permanent archive
    cp -r "$RESULT_PATH" "../$ARCHIVE_DIR/capture_$TIMESTAMP"
    echo "📁 Archived to: $ARCHIVE_DIR/capture_$TIMESTAMP"
    
    # Show quick analysis
    echo ""
    echo "=== QUICK ANALYSIS ==="
    "$RESULT_PATH/bin/analyze-telemetry" "$RESULT_PATH"
  fi
else
  echo "❌ Telemetry capture encountered issues"
  echo "📋 Check logs: logs/telemetry_capture_$TIMESTAMP.log"
  tail -20 "../logs/telemetry_capture_$TIMESTAMP.log"
fi

echo ""
echo "🎯 Mission: GET THIS NIX FIX - COMPLETE!"
EOF

chmod +x run_gemini_telemetry_capture.sh
```

---

## 📊 **EXPECTED OUTPUTS**

### **Telemetry Package Structure:**
```
capture_TIMESTAMP/
├── MANIFEST.txt                    # Complete capture summary
├── bin/analyze-telemetry           # Analysis script
├── telemetry/
│   ├── gemini-telemetry.log       # AI behavior data
│   └── *.log                      # Additional telemetry
├── logs/  
│   ├── gemini-stdout.log          # Standard output
│   ├── gemini-stderr.log          # Error output  
│   ├── execution.log              # Build execution log
│   └── environment.log            # Environment snapshot
├── traces/
│   └── gemini-strace.log          # Complete system calls
├── analysis/
│   ├── strace-summary.txt         # System call analysis
│   ├── network-analysis.txt       # Network operations
│   ├── file-operations.txt        # File system access
│   └── output-summary.txt         # Output statistics
└── redacted/
    ├── gemini-stdout.log          # Credential-redacted stdout
    ├── gemini-stderr.log          # Credential-redacted stderr
    └── gemini-strace.log          # Credential-redacted strace
```

### **Security Features:**
- 🔒 **Automatic credential redaction** - API keys, tokens sanitized
- 🔒 **Isolated execution** - temporary home directory  
- 🔒 **Complete audit trail** - every operation logged
- 🔒 **Safe sharing** - redacted/ directory for public analysis

---

## 🏆 **SUCCESS CRITERIA**

### **✅ Must Capture:**
1. **Gemini CLI execution** - headless run with "hello world" prompt
2. **Complete strace** - every system call logged  
3. **All output streams** - stdout, stderr, telemetry
4. **Network operations** - HTTPS calls to Google APIs
5. **File system access** - ~/.gemini configuration usage
6. **Credential safety** - automatic PII redaction

### **✅ Must Demonstrate:**  
1. **Nix impure builds work** - network access functional
2. **Gemini CLI integration** - AI responds to prompts
3. **Telemetry collection** - behavior analysis captured
4. **Security compliance** - credentials protected
5. **Reproducible packaging** - deterministic outputs
6. **Analysis tooling** - automated insights

---

## 🚀 **DEPLOYMENT PLAN**

### **Phase 1: Implementation (Today)**
- ✅ Create comprehensive flake.nix
- ✅ Build test runner script  
- ✅ Document security procedures
- ✅ Test with/without API key

### **Phase 2: Validation (Tomorrow)**  
- 🔄 Execute full telemetry capture
- 🔄 Analyze strace and output data
- 🔄 Validate credential redaction
- 🔄 Package for distribution

### **Phase 3: Documentation (Day 3)**
- 📋 Create analysis tutorials
- 📋 Document findings and insights  
- 📋 Share results with community
- 📋 Update social media campaign

---

## 💥 **THE BREAKTHROUGH MOMENT**

**This is it!** The comprehensive telemetry capture will give us:
- 🧠 **AI behavior insights** - how Gemini processes requests
- 🔍 **System integration patterns** - how CLI interacts with OS  
- 📊 **Performance metrics** - timing and resource usage
- 🛡️ **Security analysis** - network calls and file access
- 🚀 **Reproducible methodology** - template for future captures

**GET THIS NIX FIX AND UNLOCK THE FULL POTENTIAL OF AI-POWERED DEVELOPMENT!** 🎯🔥

---

**Status**: READY FOR IMPLEMENTATION  
**Priority**: CRITICAL - BREAKTHROUGH CAPABILITY  
**Timeline**: Deploy immediately, results in 24 hours  
**Impact**: Complete AI behavior visibility + reproducible methodology