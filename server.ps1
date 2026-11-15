# ===================================================================
# GK Hemanth Portfolio - Localhost Web & API Server
# Zero-dependency PowerShell HTTP Server with Contact Form Backend
# ===================================================================

param(
    [int]$Port = 3000,
    [string]$RootPath = $PSScriptRoot
)

if (-not $RootPath) {
    $RootPath = (Get-Location).Path
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   GK HEMANTH - PORTFOLIO WEB SERVER" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Document Root: $RootPath" -ForegroundColor Gray

# MIME Types Dictionary
$MimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".pdf"  = "application/pdf"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".txt"  = "text/plain; charset=utf-8"
}

# Bind TcpListener
$Listener = $null
$CandidatePorts = @($Port, 3001, 8080, 8000, 5000)

foreach ($p in $CandidatePorts) {
    try {
        $Listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $p)
        $Listener.Start()
        $Port = $p
        break
    } catch {
        Write-Host "Port $p is busy or unavailable. Trying next port..." -ForegroundColor Yellow
        $Listener = $null
    }
}

if (-not $Listener) {
    Write-Error "Failed to start server on any candidate port."
    exit 1
}

$ServerUrl = "http://localhost:$Port"
Write-Host ""
Write-Host ">>> SERVER RUNNING AT: $ServerUrl <<<" -ForegroundColor Magenta
Write-Host "Open this URL in your web browser to view your portfolio!" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server.`n" -ForegroundColor DarkGray

$MessagesFile = Join-Path $RootPath "data\messages.json"
if (-not (Test-Path $MessagesFile)) {
    New-Item -ItemType File -Path $MessagesFile -Value "[]" -Force | Out-Null
}

try {
    while ($true) {
        $client = $Listener.AcceptTcpClient()
        $client.ReceiveTimeout = 3000
        $client.SendTimeout = 3000

        try {
            $stream = $client.GetStream()
            $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8)

            # Read Request Line
            $requestLine = $reader.ReadLine()
            if (-not $requestLine) {
                $client.Close()
                continue
            }

            $tokens = $requestLine -split '\s+'
            if ($tokens.Count -lt 2) {
                $client.Close()
                continue
            }

            $method = $tokens[0].ToUpper()
            $rawPath = $tokens[1]
            $urlPath = $rawPath.Split('?')[0]

            # Read Headers
            $headers = @{}
            $contentLength = 0
            while ($true) {
                $hLine = $reader.ReadLine()
                if ([string]::IsNullOrEmpty($hLine)) { break }
                $colonIdx = $hLine.IndexOf(':')
                if ($colonIdx -gt 0) {
                    $hName = $hLine.Substring(0, $colonIdx).Trim().ToLower()
                    $hVal = $hLine.Substring($colonIdx + 1).Trim()
                    $headers[$hName] = $hVal
                    if ($hName -eq "content-length") {
                        [int]::TryParse($hVal, [ref]$contentLength) | Out-Null
                    }
                }
            }

            # Handle OPTIONS preflight
            if ($method -eq "OPTIONS") {
                $optHeader = "HTTP/1.1 204 No Content`r`nAccess-Control-Allow-Origin: *`r`nAccess-Control-Allow-Methods: GET, POST, OPTIONS`r`nAccess-Control-Allow-Headers: Content-Type`r`nConnection: close`r`n`r`n"
                $optBytes = [System.Text.Encoding]::ASCII.GetBytes($optHeader)
                $stream.Write($optBytes, 0, $optBytes.Length)
                $client.Close()
                continue
            }

            # Handle GET /api/messages (Inbox viewer)
            if ($method -eq "GET" -and $urlPath -eq "/api/messages") {
                $existingRaw = Get-Content -Path $MessagesFile -Raw -ErrorAction SilentlyContinue
                if (-not $existingRaw) { $existingRaw = "[]" }
                $msgBytes = [System.Text.Encoding]::UTF8.GetBytes($existingRaw)
                $headerStr = "HTTP/1.1 200 OK`r`nContent-Type: application/json; charset=utf-8`r`nAccess-Control-Allow-Origin: *`r`nCache-Control: no-cache`r`nContent-Length: $($msgBytes.Length)`r`nConnection: close`r`n`r`n"
                $hBytes = [System.Text.Encoding]::ASCII.GetBytes($headerStr)
                $stream.Write($hBytes, 0, $hBytes.Length)
                $stream.Write($msgBytes, 0, $msgBytes.Length)
                $client.Close()
                continue
            }

            # Handle Contact Form POST /api/contact
            if ($method -eq "POST" -and $urlPath -eq "/api/contact") {
                $bodyChars = [char[]]::new($contentLength)
                $totalRead = 0
                while ($totalRead -lt $contentLength) {
                    $read = $reader.Read($bodyChars, $totalRead, $contentLength - $totalRead)
                    if ($read -le 0) { break }
                    $totalRead += $read
                }
                $body = [string]::new($bodyChars, 0, $totalRead)

                # Append message to data/messages.json
                try {
                    $newMsg = $null
                    if ($body.Trim().StartsWith("{")) {
                        $newMsg = $body | ConvertFrom-Json
                    } else {
                        # Form urlencoded
                        $parsedParams = @{}
                        $body.Split('&') | ForEach-Object {
                            $kv = $_.Split('=')
                            if ($kv.Length -eq 2) {
                                $parsedParams[[System.Uri]::UnescapeDataString($kv[0])] = [System.Uri]::UnescapeDataString($kv[1].Replace('+', ' '))
                            }
                        }
                        $newMsg = [PSCustomObject]@{
                            name = $parsedParams["name"]
                            email = $parsedParams["email"]
                            subject = $parsedParams["subject"]
                            message = $parsedParams["message"]
                            timestamp = (Get-Date).ToString("o")
                        }
                    }
                    $existingRaw = Get-Content -Path $MessagesFile -Raw -ErrorAction SilentlyContinue
                    $existingList = @()
                    if ($existingRaw) {
                        try {
                            $parsed = $existingRaw | ConvertFrom-Json
                            if ($parsed -is [System.Collections.IEnumerable]) {
                                $existingList = [System.Collections.ArrayList]@($parsed)
                            } else {
                                $existingList = [System.Collections.ArrayList]@($parsed)
                            }
                        } catch {
                            $existingList = [System.Collections.ArrayList]@()
                        }
                    }

                    $msgObj = [PSCustomObject]@{
                        name      = $newMsg.name
                        email     = $newMsg.email
                        subject   = $newMsg.subject
                        message   = $newMsg.message
                        received  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                        timestamp = $newMsg.timestamp
                    }

                    $existingList.Add($msgObj) | Out-Null
                    $jsonToSave = $existingList | ConvertTo-Json -Depth 5
                    [System.IO.File]::WriteAllText($MessagesFile, $jsonToSave, [System.Text.Encoding]::UTF8)

                    Write-Host "[POST 200] Contact submission from: $($newMsg.name) <$($newMsg.email)>" -ForegroundColor Green

                    $resJson = '{"success": true, "message": "Thank you! Your message has been received."}'
                    $resBytes = [System.Text.Encoding]::UTF8.GetBytes($resJson)
                    $headerStr = "HTTP/1.1 200 OK`r`nContent-Type: application/json; charset=utf-8`r`nAccess-Control-Allow-Origin: *`r`nContent-Length: $($resBytes.Length)`r`nConnection: close`r`n`r`n"
                    $hBytes = [System.Text.Encoding]::ASCII.GetBytes($headerStr)
                    $stream.Write($hBytes, 0, $hBytes.Length)
                    $stream.Write($resBytes, 0, $resBytes.Length)
                } catch {
                    Write-Host "[POST 500] Error processing contact form: $_" -ForegroundColor Red
                    $errJson = '{"success": false, "message": "Error processing request."}'
                    $errBytes = [System.Text.Encoding]::UTF8.GetBytes($errJson)
                    $headerStr = "HTTP/1.1 500 Internal Server Error`r`nContent-Type: application/json`r`nContent-Length: $($errBytes.Length)`r`nConnection: close`r`n`r`n"
                    $hBytes = [System.Text.Encoding]::ASCII.GetBytes($headerStr)
                    $stream.Write($hBytes, 0, $hBytes.Length)
                    $stream.Write($errBytes, 0, $errBytes.Length)
                }

                $client.Close()
                continue
            }

            # Map Static File Path
            if ($urlPath -eq "/" -or $urlPath -eq "") {
                $filePath = Join-Path $RootPath "index.html"
            } else {
                $relPath = [System.Uri]::UnescapeDataString($urlPath.TrimStart('/'))
                $relPath = $relPath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
                $filePath = Join-Path $RootPath $relPath
            }

            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $contentType = if ($MimeTypes.ContainsKey($ext)) { $MimeTypes[$ext] } else { "application/octet-stream" }

                $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
                $headerStr = "HTTP/1.1 200 OK`r`nContent-Type: $contentType`r`nContent-Length: $($fileBytes.Length)`r`nAccess-Control-Allow-Origin: *`r`nCache-Control: no-cache`r`nConnection: close`r`n`r`n"
                $hBytes = [System.Text.Encoding]::ASCII.GetBytes($headerStr)

                $stream.Write($hBytes, 0, $hBytes.Length)
                $stream.Write($fileBytes, 0, $fileBytes.Length)

                Write-Host "[200 OK] $method $urlPath ($($fileBytes.Length) bytes)" -ForegroundColor Cyan
            } else {
                $notFoundMsg = "<html><body><h1>404 Not Found</h1><p>File not found: $urlPath</p></body></html>"
                $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($notFoundMsg)
                $headerStr = "HTTP/1.1 404 Not Found`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($bodyBytes.Length)`r`nConnection: close`r`n`r`n"
                $hBytes = [System.Text.Encoding]::ASCII.GetBytes($headerStr)

                $stream.Write($hBytes, 0, $hBytes.Length)
                $stream.Write($bodyBytes, 0, $bodyBytes.Length)

                Write-Host "[404 Not Found] $method $urlPath" -ForegroundColor DarkYellow
            }
        } catch {
            # Client disconnected or stream error
        } finally {
            $client.Close()
        }
    }
} finally {
    if ($Listener) {
        $Listener.Stop()
        Write-Host "Server stopped." -ForegroundColor Red
    }
}
