$ErrorActionPreference = "Stop"

$previousEnvironment = $env:ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT

try {
    $env:ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT = "production"
    flutter build apk --release `
        --dart-define=ADMOB_ENVIRONMENT=production
} finally {
    if ($null -eq $previousEnvironment) {
        Remove-Item Env:ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT `
            -ErrorAction SilentlyContinue
    } else {
        $env:ORG_GRADLE_PROJECT_ADMOB_ENVIRONMENT = $previousEnvironment
    }
}
