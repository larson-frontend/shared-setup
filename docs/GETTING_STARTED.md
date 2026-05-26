

# 🚀 Getting Started with Project Development

> Complete setup guide from cloning repository to running the development stack
> 
> **Note:** This is a template guide. Adjust paths and commands for your specific project.

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **Git** (v2.30+): `git --version`
- **Node.js** (v18+): `node --version` && `npm --version`
- **Java 21**: `java -version` (for backend)
- **Maven** (v3.8+): `mvn --version` (for backend)
- **Docker & Docker Compose** (optional, for database): `docker --version`
- **PostgreSQL** (v15+ OR use Docker)
- **macOS/Linux** (or WSL2 on Windows)

---

## 🔧 Step 1: Clone the Repository

```bash
# Clone the main repository
git clone <YOUR_REPO_URL>
cd <YOUR_PROJECT_DIR>

# Initialize submodules (includes shared-instructions)
git submodule update --init --recursive

# Verify submodule is loaded
ls -la shared-instructions/
# Should show: agent-usage.md, copilot.instructions.md, TEAM_SETUP_GUIDE.md, etc.
```

**Replace:**
- `<YOUR_REPO_URL>` with your repository URL
- `<YOUR_PROJECT>` with your project directory name

---

## 📁 Step 2: Understand the Project Structure

```
<root-workspace>/
├── shared-instructions/                  # Shared docs (symlinked in projects)
│   ├── copilot.instructions.md          # Copilot agent instructions
│   ├── agent-usage.md                   # Agent usage history
│   ├── TEAM_SETUP_GUIDE.md              # Team onboarding
│   ├── README.md                        # This documentation hub
│   └── agents/                          # Agent-specific configs
├── <project-1>/                          # Project 1 (e.g., frontend)
│   ├── src/                             # Source code
│   ├── .vscode/settings.json            # Copilot instructions (symlinked)
│   └── shared-instructions/ → ../shared-instructions  (symlink)
├── <project-2>/                          # Project 2 (e.g., backend)
│   ├── src/                             # Source code
│   ├── .vscode/settings.json            # Copilot instructions (symlinked)
│   └── shared-instructions/ → ../shared-instructions  (symlink)
└── <additional-projects>/               # Additional projects (optional)
```

**Your projects:**
- Replace `<root-workspace>` with your workspace directory
- Replace `<project-1>`, `<project-2>` with your actual project names
- Both projects symlink to the same `shared-instructions/` for consistency

Run the canonical post-install verification command after setup:

```bash
./shared-instructions/scripts/verify-install.sh --project-root .
```

---
## 🗂️ Step 3: Setup Infrastructure (If Required)

### Database Setup (Backend Projects)

**Option A: Docker (Recommended)**
```bash
cd <backend-project>
docker-compose up -d
```

**Option B: Local Installation**
- Install your required database (PostgreSQL, MySQL, MongoDB, etc.)
- Create development database
- Configure connection string in your project's config file

**Check your project's README or `docker-compose.yml` for specific setup instructions.**
```

---

## 🔨 Step 4: Build & Run Backend

```
## 🔨 Step 4: Build & Run Backend Services

**This step depends on your backend technology stack.**

### For Java/Maven Projects
```bash
cd <backend-project>
mvn clean install      # Build and run tests
mvn spring-boot:run    # Run server
```

### For Node.js/npm Projects
```bash
cd <backend-project>
npm install            # Install dependencies
npm start              # Start server
# OR: npm run dev      # Development with watch mode
```

### For Python Projects
```bash
cd <backend-project>
pip install -r requirements.txt
python manage.py runserver  # or your project's run command
```

### For Go/Rust/Other Languages
```bash
cd <backend-project>
## 🎨 Step 5: Build & Run Frontend Services

**For Node.js/npm-based frontends:**

```bash
cd <frontend-project>

# Install npm dependencies
npm install

# Run development server
npm run dev
# Output will show the running URL (typically http://localhost:3000 or 5173)
```

## 🧪 Step 6: Verify Installation Setup

Use the canonical installer verifier to confirm setup is complete:

```bash
./shared-instructions/scripts/verify-install.sh --project-root .
```

Setup verification must pass before continuing.

### Basic Setup Verification (Post-Install Smoke Checks)

**Backend verification:**
```bash
# Check if backend is responding
curl http://localhost:8080/health  # Or your backend port/endpoint
# OR visit in browser and check for 200 status
```

**Frontend verification:**
```bash
# Open in browser
open http://localhost:3000  # Or your frontend port
# Should load without errors
```

### Project-Specific Runtime and Test Validation (After Setup Verification)

After setup verification passes, run runtime, unit, integration, and E2E tests according to the target repository's own standards.

**Run project-specific tests in each project:**

```bash
# Backend tests
cd <backend-project>
mvn test                    # Maven
# OR: npm test             # Node.js
# OR: your language's test command

# Frontend tests
cd <frontend-project>
npm test                    # Most npm projects
# OR: npm run test:all     # If using custom test scripts
```

Setup verification is the install gate; project-specific tests are executed afterward.

---

## 💡 Step 7: Understanding Copilot Instructions

### How It Works

1. **Copilot reads from `.vscode/settings.json`:**
   ```json
   "copilot.instructions": [
     "shared-instructions/copilot.instructions.md"
   ]
   ```

2. **The symlink resolves automatically in each project:**
   - `<frontend-project>/shared-instructions/` → `../shared-instructions/` (root)
   - `<backend-project>/shared-instructions/` → `../shared-instructions/` (root)

3. **All projects share the same instructions:**
   - Single source of truth in `shared-instructions/copilot.instructions.md`
   - Every developer gets consistent agent behavior
   - Updates apply everywhere automatically

### Using the Agent

Open VS Code and start coding:

```bash
## 🚀 Step 8: Building for Mobile (If Applicable)

**This section only applies if your project targets mobile platforms.**

### For Capacitor/React Native/Flutter Projects

Refer to your project's specific mobile build documentation:
- Check `<project>/README.md` for mobile setup
- Look for `android/`, `ios/`, or `mobile/` directories
- Consult your framework's official documentation

**Example for Capacitor:**
```bash
npm run android:sync   # Sync web to Android
npm run ios:sync       # Sync web to iOS
```

**If your project doesn't target mobile, skip this step.** run android:open

# Build signed APK (requires keystore setup - see ANDROID_SIGNING.md)
npm run build-release-apk
```

### iOS

```bash
cd <frontend-project>

# Build and sync to iOS
npm run ios:sync

# Open Xcode
npm run ios:open

## 📱 Step 9: Deployment & Publication (If Applicable)

**This section applies only if you're preparing for production deployment or app store publication.**
This is a release/deployment gate, not the install/setup verification step.

### Pre-Deployment Checklist

```bash
# 1. Run all tests
npm test                  # Frontend
mvn test                  # Backend (if Maven)

# 2. Build for production
npm run build             # Frontend
mvn clean package         # Backend (if Maven)

# 3. Run any project-specific validation
# Check your project's README for additional checks
```

### For Publication

- Check your project's documentation for publication guides
- Follow your platform's submission process (e.g., App Store, Google Play)
- Skip if your project does not require publication

---

## 🔒 Security & Environment Variables

### Frontend Production

Create `.env.production` in `<frontend-project>/`:

```env
## 🔒 Security & Environment Variables

### Development vs. Production

**Development:**
- Use default configuration (often provided in project)
- Store sensitive values in `.env.local` or `.env.development`
- Never commit `.env.local` to git

**Production:**
- Use `.env.production` (if tracked) OR environment variables
- Store secrets in secure vaults (GitHub Secrets, AWS Secrets Manager, etc.)
- Rotate secrets regularly

### Setting Environment Variables

**Option 1: Environment File**
```bash
# Create .env.local (not tracked by git)
echo "DB_PASSWORD=secure_value" > .env.local
echo "API_KEY=your_api_key" >> .env.local
```

**Option 2: Shell Environment**
```bash
## 🐛 Troubleshooting

### General Issues

```bash
# Port already in use (Linux/macOS)
lsof -i :<PORT>          # Find process using port
kill -9 <PID>            # Terminate process

# Clear caches and reinstall
rm -rf node_modules package-lock.json
npm install

# Submodule not loading
git submodule update --init --recursive

# Verify symlinks
ls -la <project>/shared-instructions
# Should show: shared-instructions -> ../shared-instructions
```

### Backend Issues

```bash
# Restart infrastructure
docker-compose restart

# Check database connection
# Verify database service is running and accessible

# Review logs
docker-compose logs <service-name>
```

### Frontend Issues

```bash
# Clear build cache
npm run clean  # (if available) or rm -rf dist/

# Test failing
npm test -- --verbose

# Type errors
npm run type-check  # (if using TypeScript)
```

**See your project's README for project-specific troubleshooting.**ymlink issues (Windows)
# Use: git config core.symlinks true
# Then: git reset --hard HEAD

## 📚 Documentation Files

| File | Purpose | Location |
|------|---------|----------|
| **README.md** (in each project) | Project-specific setup | Each project directory |
| **TEAM_SETUP_GUIDE.md** | Team workflow & standards | `shared-instructions/` |
| **copilot.instructions.md** | Agent instructions | `shared-instructions/` |
| **agent-usage.md** | Agent usage history | `shared-instructions/` |

**Check each project's directory for additional documentation specific to that project.**
| **README.md** (in each project) | Project-specific setup | Each project |
| **TEAM_SETUP_GUIDE.md** | Team workflow & standards | `shared-instructions/` |
| **copilot.instructions.md** | Agent instructions | `shared-instructions/` |
| **agent-usage.md** | History/patterns | `shared-instructions/` |
## 🚀 Quick Reference - Common Commands

### Universal Commands

```bash
# Repository
git clone <repo>                  # Clone repository
git submodule update --init       # Initialize submodules
git checkout -b feature/<name>    # Create feature branch

# npm-based Projects
npm install                       # Install dependencies
npm start / npm run dev          # Start dev server
npm test                         # Run tests
npm run build                    # Production build
npm run lint                     # Lint code

# Maven-based Projects
mvn clean install                # Build with tests
mvn test                         # Run tests
mvn spring-boot:run             # Run server
mvn clean package                # Build without tests

# Docker
docker-compose up -d             # Start services
docker-compose down              # Stop services
docker-compose logs <service>    # View logs
```

**Your specific project may have different commands. Check `package.json` or `pom.xml` for available scripts.** run ios:open              # Open Xcode

# Database
docker-compose up -d <db-service>  # Start your database service
docker-compose down                 # Stop all services
## 🎯 Next Steps After Setup

1. ✅ **Read the team documentation**
   - Review `shared-instructions/TEAM_SETUP_GUIDE.md` for workflow
   - Check `shared-instructions/copilot.instructions.md` for agent behavior

2. ✅ **Try the Copilot agent**
   - Open VS Code in your project
   - Press `⌘ + I` (Mac) or `Ctrl + I` (Linux/Windows)
   - Ask for help with your code

3. ✅ **Run tests to verify setup**
   - `npm test` or `mvn test`
   - All tests should pass

4. ✅ **Explore the codebase**
   - Read project-specific README
   - Review documentation in each project directory

5. ✅ **Start development**
   - Create a feature branch: `git checkout -b feature/<your-feature>`
   - Make changes, commit, push
   - Open a pull request for review
## 📞 Getting Help

- **Copilot Chat**: Press `⌘ + I` (Mac) or `Ctrl + I` to ask the agent
- **Documentation**: 
  - Shared: Check `shared-instructions/` directory
  - Project-specific: Check each project's README
- **Tests**: Run test suite to verify your setup
- **Git**: Review commit history for examples

---

**Last Updated:** December 20, 2025
**Version:** 1.0.0
**Type:** Abstract Template (Adapt for your project)

---

> 💡 **Tip:** Replace all project-specific values with yours. This is a template guide designed to work across different technology stacks and project structures.
**Status:** Production Ready ✅

---

> 💡 **Tip:** The Copilot agent is available in your workspace. It reads instructions from `shared-instructions/copilot.instructions.md` and provides context-aware help for your task at hand!
