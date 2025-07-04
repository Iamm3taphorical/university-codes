# Auto-upload script for University Codes
# Created for: iamm3taphorical
# Repository: university-codes

Write-Host "🎓 Auto-uploading University Codes to GitHub..." -ForegroundColor Green
Write-Host "Repository: university-codes" -ForegroundColor Cyan
Write-Host "User: iamm3taphorical" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Green

# Check if we're in the university-codes directory
$currentPath = Get-Location
if ($currentPath.Path -notlike "*university-codes*") {
    Write-Host "❌ Please run this script from the university-codes directory!" -ForegroundColor Red
    Write-Host "Current location: $currentPath" -ForegroundColor Yellow
    Write-Host "Expected: C:\Users\hp\university-codes" -ForegroundColor Yellow
    exit 1
}

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "❌ Not a git repository! Please ensure git is initialized." -ForegroundColor Red
    exit 1
}

# Show current status
Write-Host "📊 Checking for changes..." -ForegroundColor Yellow
$status = git status --porcelain

if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "ℹ️  No changes to upload." -ForegroundColor Yellow
    Write-Host "📁 Current repository status is up to date." -ForegroundColor Green
    exit 0
}

Write-Host "📁 Changes detected:" -ForegroundColor Yellow
git status --short

Write-Host "`n🔍 Files to be uploaded:" -ForegroundColor Cyan
$addedFiles = git diff --cached --name-only
$modifiedFiles = git diff --name-only
$untrackedFiles = git ls-files --others --exclude-standard

if ($untrackedFiles) {
    Write-Host "  📄 New files:" -ForegroundColor Green
    $untrackedFiles | ForEach-Object { Write-Host "    + $_" -ForegroundColor Green }
}

if ($modifiedFiles) {
    Write-Host "  📝 Modified files:" -ForegroundColor Yellow
    $modifiedFiles | ForEach-Object { Write-Host "    ~ $_" -ForegroundColor Yellow }
}

# Add all changes
Write-Host "`n📦 Adding all changes..." -ForegroundColor Yellow
git add .

# Get commit message from user
Write-Host "`n💬 Commit Message Options:" -ForegroundColor Cyan
Write-Host "1. Auto-generate based on changes" -ForegroundColor White
Write-Host "2. Enter custom message" -ForegroundColor White
Write-Host "3. Course-specific message" -ForegroundColor White

$choice = Read-Host "Choose option (1-3, or press Enter for option 1)"

switch ($choice) {
    "2" {
        $commitMessage = Read-Host "Enter your custom commit message"
        if ([string]::IsNullOrWhiteSpace($commitMessage)) {
            $commitMessage = "Update: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        }
    }
    "3" {
        $courseCode = Read-Host "Enter course code (e.g., CSE220)"
        $assignmentType = Read-Host "Enter type (assignment/lab/project/solution/question)"
        $description = Read-Host "Enter brief description"
        
        if ([string]::IsNullOrWhiteSpace($courseCode)) { $courseCode = "COURSE" }
        if ([string]::IsNullOrWhiteSpace($assignmentType)) { $assignmentType = "update" }
        if ([string]::IsNullOrWhiteSpace($description)) { $description = "files" }
        
        $commitMessage = "$($courseCode.ToUpper()): Add $assignmentType - $description"
    }
    default {
        # Auto-generate message based on file changes
        $newFiles = (git diff --cached --name-only --diff-filter=A | Measure-Object).Count
        $modFiles = (git diff --cached --name-only --diff-filter=M | Measure-Object).Count
        $delFiles = (git diff --cached --name-only --diff-filter=D | Measure-Object).Count
        
        $parts = @()
        if ($newFiles -gt 0) { $parts += "$newFiles new file$(if($newFiles -gt 1){'s'})" }
        if ($modFiles -gt 0) { $parts += "$modFiles modified" }
        if ($delFiles -gt 0) { $parts += "$delFiles deleted" }
        
        $changesSummary = $parts -join ", "
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $commitMessage = "University update: $changesSummary ($timestamp)"
    }
}

Write-Host "💾 Committing changes: '$commitMessage'" -ForegroundColor Yellow

# Commit changes
try {
    git commit -m "$commitMessage"
    Write-Host "✅ Changes committed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Error committing changes: $_" -ForegroundColor Red
    exit 1
}

# Push to GitHub
Write-Host "📤 Pushing to GitHub..." -ForegroundColor Yellow
try {
    git push origin main
    Write-Host "✅ Upload completed successfully!" -ForegroundColor Green
    Write-Host "🌐 View your repository at: https://github.com/iamm3taphorical/university-codes" -ForegroundColor Cyan
    
    # Show upload summary
    Write-Host "`n📋 Upload Summary:" -ForegroundColor Cyan
    Write-Host "  📅 Date: $(Get-Date -Format 'MMMM dd, yyyy HH:mm:ss')" -ForegroundColor White
    Write-Host "  📝 Commit: $commitMessage" -ForegroundColor White
    Write-Host "  📊 Total files in repo: $((git ls-files | Measure-Object).Count)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error pushing to GitHub: $_" -ForegroundColor Red
    Write-Host "💡 Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "   - Check internet connection" -ForegroundColor White
    Write-Host "   - Verify GitHub repository exists: university-codes" -ForegroundColor White
    Write-Host "   - Ensure remote origin is set correctly" -ForegroundColor White
    exit 1
}

Write-Host "`n🎉 All done! Your university codes are now on GitHub." -ForegroundColor Green
Write-Host "📚 Keep coding and learning! 🚀" -ForegroundColor Magenta
