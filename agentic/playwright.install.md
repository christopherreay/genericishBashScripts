# Playwright Agentic Setup Protocol

## Decision Tree for Claude Code

```
Playwright Context Assessment
|
├─ Environment Detection
│  ├─ Check: `command -v node` (Node.js available?)
│  ├─ Check: `ls package.json` (Project initialized?)
│  ├─ Check: `ls node_modules/playwright` (Local install?)
│  └─ Check: `npx playwright --version` (Global access?)
│
├─ Context Classification
│  ├─ [Fresh Context] - No package.json, no Playwright
│  ├─ [Existing Project] - Has package.json, missing Playwright
│  ├─ [Playwright Ready] - Has Playwright, needs config verification
│  └─ [Unknown State] - Mixed signals, needs investigation
│
└─ Action Selection
   ├─ Fresh Context → Full setup protocol
   ├─ Existing Project → Add Playwright to existing
   ├─ Playwright Ready → Verify and enhance config
   └─ Unknown State → Safe discovery and minimal setup
```

## Execution Commands by Context

### Fresh Context (New Project)
```bash
# Run the full setup script
curl -sSL https://raw.githubusercontent.com/user/repo/main/setup-playwright.sh | bash
# OR if script is local:
./setup-playwright.sh
```

### Existing Project
```bash
npm install -D playwright @playwright/test
npx playwright install
npx playwright install-deps  # If Debian/Ubuntu
```

### Verification Protocol
```bash
# Test Playwright availability
npx playwright --version

# Test basic functionality
npx playwright test tests/example.spec.js --reporter=line
```

## Claude Code Integration Pattern

When Claude Code needs Playwright functionality:

1. **Pre-flight Check**: Always verify Playwright availability before generating test code
2. **Auto-setup Trigger**: If Playwright missing, execute setup protocol automatically
3. **Context Preservation**: Maintain awareness of project structure post-setup
4. **Error Recovery**: If setup fails, fall back to documentation generation instead of code

## Configuration Templates

### Minimal Config (Quick Start)
```javascript
module.exports = {
  testDir: './tests',
  use: { headless: true },
  projects: [{ name: 'chromium', use: {} }]
};
```

### Agentic-Optimized Config (Recommended)
```javascript
module.exports = {
  testDir: './tests',
  timeout: 30000,
  fullyParallel: false,  // Sequential for agent coordination
  workers: 1,           // Single worker prevents conflicts
  retries: 2,           // Resilience for flaky tests
  use: {
    headless: true,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure'
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } }
  ]
};
```

## File Structure Post-Setup

```
project-root/
├─ package.json              # Node.js project config
├─ playwright.config.js      # Playwright configuration
├─ tests/                   # Test files directory
│  ├─ example.spec.js       # Sample test
│  └─ [claude-generated]/   # Claude Code test output
├─ utils/                   # Helper functions
│  └─ playwright-helpers.js # Reusable utilities
├─ screenshots/             # Test artifacts
├─ test-results/           # Test output
└─ node_modules/           # Dependencies
   └─ playwright/          # Playwright installation
```

## Error Handling Protocols

### Common Issues & Resolutions

| Issue | Detection | Resolution |
|-------|-----------|------------|
| Missing browsers | `Error: browserType.launch()` | `npx playwright install` |
| System deps missing | Browser launch fails | `npx playwright install-deps` |
| Permissions error | EACCES in browser dir | Check file permissions, may need `sudo` |
| Config not found | `Error: No tests found` | Verify `playwright.config.js` exists |

### Fallback Strategies

1. **Graceful Degradation**: Generate documentation instead of executable tests
2. **Alternative Tools**: Suggest Selenium or Puppeteer if Playwright fails
3. **Manual Instructions**: Provide step-by-step setup if automation fails

## Success Criteria

- ✅ `npx playwright --version` returns version number
- ✅ `npx playwright test` can execute without errors
- ✅ Configuration file exists and is valid
- ✅ Test directory structure is in place
- ✅ Claude Code can generate and execute browser tests

## Usage Examples for Claude Code

```bash
# Check if setup needed
if ! npx playwright --version &>/dev/null; then
  echo "Setting up Playwright..."
  ./setup-playwright.sh
fi

# Generate and run a test
npx playwright codegen example.com
npx playwright test --reporter=line
```
