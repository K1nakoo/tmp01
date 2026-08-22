# BENIGN build.ps1 -- the "normal" script on the main branch.
# Runs on a real GitHub-hosted runner via `shell: pwsh` -> `./build.ps1`
# after the job has been granted contents: write + id-token: write.
Write-Output "== build started =="
Write-Output "runner: $env:RUNNER_NAME"
Write-Output "repository: $env:GITHUB_REPOSITORY"
Write-Output "ref: $env:GITHUB_REF"
# the benign script does not touch the token or OIDC endpoint
Write-Output "build complete"
