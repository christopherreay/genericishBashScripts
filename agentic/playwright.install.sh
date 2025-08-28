#!/bin/bash

# Playwright Auto-Setup for Claude Code
# Detects context and installs Playwright appropriately

set -euo pipefail

echo "🎭 Playwright Auto-Setup for Claude Code"
echo "========================================"

# Detection functions
has_package_json() { [[ -f "package.json" ]]; }
has_playwright() { [[ -d "node_modules/playwright" ]] || command -v playwright >/dev/null 2>&1; }
has_node() { command -v node >/dev/null 2>&1; }
is_debian() { [[ -f "/etc/debian_version" ]]; }

# Setup Node.js if missing (Debian)
setup_node() {
    if ! has_node; then
        echo "📦 Installing Node.js..."
        if is_debian; then
            sudo apt update
            sudo apt install -y curl
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt install -y nodejs
        else
            echo "❌ Node.js not found. Please install Node.js first."
            exit 1
        fi
    fi
    echo "✅ Node.js version: $(node --version)"
}

# Install system dependencies (Debian)
install_system_deps() {
    if is_debian; then
        echo "🔧 Installing system dependencies..."
        sudo apt update
        sudo apt install -y \
            libnss3-dev \
            libatk-bridge2.0-dev \
            libdrm2-dev \
            libgtk-3-dev \
            libgbm-dev \
            libasound2-dev
    fi
}

# Setup package.json if missing
setup_package_json() {
    if ! has_package_json; then
        echo "📄 Creating package.json..."
        npm init -y
        # Configure for Claude Code usage
        cat > package.json << 'EOF'
{
  "name": "claude-code-workspace",
  "version": "1.0.0",
  "description": "Workspace for Claude Code with Playwright",
  "main": "index.js",
  "scripts": {
    "test": "playwright test",
    "test:headed": "playwright test --headed",
    "test:debug": "playwright test --debug"
  },
  "keywords": ["playwright", "testing", "claude-code"],
  "author": "",
  "license": "MIT"
}
EOF
    fi
}

# Install Playwright
install_playwright() {
    echo "🎭 Installing Playwright..."
    npm install -D playwright @playwright/test
    
    echo "🌐 Installing browser binaries..."
    npx playwright install
    
    # Install system dependencies for browsers
    if is_debian; then
        echo "🔧 Installing browser system dependencies..."
        npx playwright install-deps
    fi
}

# Create Playwright config
create_config() {
    if [[ ! -f "playwright.config.js" ]]; then
        echo "⚙️ Creating Playwright configuration..."
        cat > playwright.config.js << 'EOF'
// Playwright config optimized for Claude Code usage
const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 30 * 1000,
  expect: {
    timeout: 5000
  },
  
  // Sequential execution for agentic coordination
  fullyParallel: false,
  workers: 1,
  
  // Reporter configuration
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results.json' }]
  ],
  
  use: {
    // Essential for server/headless environments
    headless: true,
    
    // Debugging aids
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
    
    // Default timeouts
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
EOF
    fi
}

# Create example test structure
create_test_structure() {
    if [[ ! -d "tests" ]]; then
        echo "📁 Creating test structure..."
        mkdir -p tests
        
        cat > tests/example.spec.js << 'EOF'
// Example Playwright test for Claude Code
const { test, expect } = require('@playwright/test');

test('example test', async ({ page }) => {
  await page.goto('https://example.com');
  await expect(page).toHaveTitle(/Example Domain/);
});
EOF

        mkdir -p utils
        cat > utils/playwright-helpers.js << 'EOF'
// Helper functions for Claude Code Playwright usage
const { expect } = require('@playwright/test');

class PlaywrightHelpers {
  static async waitForElement(page, selector, timeout = 5000) {
    return await page.waitForSelector(selector, { timeout });
  }
  
  static async takeScreenshot(page, name) {
    return await page.screenshot({ path: `screenshots/${name}.png` });
  }
  
  static async getElementText(page, selector) {
    const element = await page.locator(selector);
    return await element.textContent();
  }
}

module.exports = { PlaywrightHelpers };
EOF
        
        mkdir -p screenshots
    fi
}

# Verify installation
verify_installation() {
    echo "🔍 Verifying installation..."
    
    if npx playwright --version >/dev/null 2>&1; then
        echo "✅ Playwright CLI: $(npx playwright --version)"
    else
        echo "❌ Playwright CLI not working"
        exit 1
    fi
    
    if [[ -f "playwright.config.js" ]]; then
        echo "✅ Configuration file created"
    fi
    
    if [[ -d "tests" ]]; then
        echo "✅ Test directory structure created"
    fi
    
    echo ""
    echo "🎉 Playwright setup complete!"
    echo "Claude Code can now generate and run Playwright tests in this context."
    echo ""
    echo "Available commands:"
    echo "  npx playwright test              # Run all tests"
    echo "  npx playwright test --headed     # Run with browser UI"
    echo "  npx playwright test --debug      # Debug mode"
    echo "  npx playwright codegen           # Generate test code"
}

# Main execution flow
main() {
    echo "🔍 Detecting current environment..."
    
    # System setup
    setup_node
    install_system_deps
    
    # Project setup
    setup_package_json
    
    # Playwright installation
    if has_playwright; then
        echo "✅ Playwright already available"
    else
        install_playwright
    fi
    
    # Configuration
    create_config
    create_test_structure
    
    # Verification
    verify_installation
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
