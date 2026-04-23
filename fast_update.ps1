# fast_update.ps1 - Skrip Otomasi Install dari Cloud
# Modal: Colok USB + GitHub CLI (gh)

$ErrorActionPreference = "Stop"

function Test-Dependencies {
    Write-Host "--- Memverifikasi Peralatan dan Koneksi HP... ---" -ForegroundColor Cyan
    try { gh --version | Out-Null } catch { Write-Error "GitHub CLI (gh) tidak ditemukan. Silakan install di cli.github.com" }
    try { adb version | Out-Null } catch { Write-Error "ADB tidak ditemukan. Pastikan Android SDK sudah terdaftar di PATH." }

    # Cek apakah HP dicolok
    $devices = adb devices | Select-String -Pattern "\tdevice$"
    if (-not $devices) {
        Write-Host "HP TIDAK TERDETEKSI!" -ForegroundColor Red
        Write-Host "Pastikan HP dicolok USB dan 'USB Debugging' sudah aktif." -ForegroundColor Yellow
        Write-Host "ketik 'adb devices' untuk memastikan secara manual." -ForegroundColor White
        throw "Tidak ada HP yang terhubung."
    } else {
        Write-Host "HP Terdeteksi: OK!" -ForegroundColor Green
    }
}

function Get-LatestRun($targetSha) {
    Write-Host "--- Mencari build terbaru di GitHub (SHA: $targetSha)... ---" -ForegroundColor Cyan
    $run = gh run list --workflow "build-apk.yml" --limit 10 --json databaseId,status,conclusion,headSha | ConvertFrom-Json | Where-Object { $_.headSha -like "$targetSha*" } | Select-Object -First 1
    return $run
}

try {
    Test-Dependencies
    $installOutput = ""

    # Ambil SHA commit terakhir di lokal
    $localSha = git rev-parse --short HEAD
    Write-Host "Mencari build untuk commit: $localSha" -ForegroundColor Yellow

    $run = $null
    $attempts = 0
    $maxAttempts = 12 # Tunggu maksimal 1 menit (5 detik x 12)

    while (-not $run -and $attempts -lt $maxAttempts) {
        $run = Get-LatestRun $localSha
        if (-not $run) {
            $attempts++
            Write-Host "Build belum terdeteksi di GitHub. Menunggu (percobaan $attempts/$maxAttempts)..." -ForegroundColor Gray
            Start-Sleep -Seconds 5
        }
    }

    if (-not $run) {
        Write-Host "TIDAK ADA BUILD DITEMUKAN untuk commit $localSha!" -ForegroundColor Red
        Write-Host "Pastikan Bapak sudah 'git push' ke branch main." -ForegroundColor Yellow
        exit
    }

    $runId = @($run.databaseId)[0]

    if ($run.status -ne "completed") {
        Write-Host "Mendeteksi build ID $runId sedang berjalan (Watch)..." -ForegroundColor Cyan
        gh run watch $runId
    } else {
        Write-Host "Build ID $runId ditemukan (Selesai dengan status: $($run.conclusion))." -ForegroundColor Green
    }

    # TANYA USER: Debug atau Release?
    Write-Host "`n--- PILIHAN VERSI APK ---" -ForegroundColor Cyan
    Write-Host "1. DEBUG   - Untuk melihat LOG / Debugging (File lebih besar)" -ForegroundColor White
    Write-Host "2. RELEASE - Untuk penggunaan normal (Ringan & Cepat)" -ForegroundColor White
    $choice = Read-Host "Pilih versi (1/2) [Default 1]"

    $mode = "debug"
    if ($choice -eq "2") { $mode = "release" }

    Write-Host "Mendownload APK (Artifact: release-artifacts)..." -ForegroundColor Cyan
    # Bersihkan folder lama
    if (Test-Path "release-artifacts") { Remove-Item -Recurse -Force "release-artifacts" }
    gh run download $runId -n "release-artifacts" -D "release-artifacts"

    # Deteksi ABI HP (Tipe Processor)
    Write-Host "Mendeteksi tipe processor HP..." -ForegroundColor Cyan
    $deviceAbi = adb shell getprop ro.product.cpu.abi
    Write-Host "HP Anda menggunakan: $deviceAbi" -ForegroundColor Yellow

    # Cari file APK yang paling cocok
    $apkFiles = Get-ChildItem -Path "release-artifacts" -Filter "*.apk" -Recurse
    $selectedApk = $null

    if ($mode -eq "debug") {
        # Cari app-debug.apk
        $selectedApk = $apkFiles | Where-Object { $_.Name -eq "app-debug.apk" } | Select-Object -First 1
    } else {
        # Cari yang sesuai ABI
        foreach ($file in $apkFiles) {
            if ($file.Name -like "*$deviceAbi*" -and $file.Name -like "*release*") {
                $selectedApk = $file
                break
            }
        }
        # Fallback jika tidak ada yang spesifik (ambil yang arm64-release)
        if (-not $selectedApk) {
            $selectedApk = $apkFiles | Where-Object { $_.Name -like "*arm64-v8a*" -and $_.Name -like "*release*" } | Select-Object -First 1
        }
    }

    if ($selectedApk) {
        Write-Host "Mempersiapkan instalasi: $($selectedApk.Name) ($mode mode)" -ForegroundColor Magenta
        # --- FITUR EKSPOR KE D:\Ve-Wallet-Builds ---
        $exportPath = "D:\Ve-Wallet-Builds"
        if (-not (Test-Path $exportPath)) { New-Item -ItemType Directory -Path $exportPath | Out-Null }
        $finalApkPath = Join-Path $exportPath "Ve-Wallet-$mode.apk"
        Copy-Item -Path $selectedApk.FullName -Destination $finalApkPath -Force
        Write-Host "APK SIAP DISHARE: $finalApkPath" -ForegroundColor Magenta
        # ---------------------------------------

        Write-Host "Menginstall ke HP via USB... (Sabar ya Ganteng..)" -ForegroundColor Green

        # Jalankan install dan tangkap output & errornya
        $oldErrorAction = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        $installOutput = adb install -r "$($selectedApk.FullName)" 2>&1
        $ErrorActionPreference = $oldErrorAction
        $isSuccess = ($LASTEXITCODE -eq 0) -and ($installOutput -notlike "*Failure*")

        if (-not $isSuccess) {
            if ($installOutput -like "*UPDATE_INCOMPATIBLE*" -or $installOutput -like "*VERSION_DOWNGRADE*") {
                Write-Host "KONFLIK VERSI / SIGNATURE TERDETEKSI! Menghapus versi lama di HP..." -ForegroundColor Yellow
                adb uninstall com.velora.ve_wallet
                Write-Host "Mencoba menginstal ulang..." -ForegroundColor Cyan
                $ErrorActionPreference = "Continue"
                $retryOutput = adb install -r "$($selectedApk.FullName)" 2>&1
                $ErrorActionPreference = "Stop"
                if (($LASTEXITCODE -eq 0) -and ($retryOutput -notlike "*Failure*")) {
                    Write-Host "### UPDATE BERHASIL (SETELAH AUTO-CLEAN)! ###" -ForegroundColor Green
                } else {
                    Write-Host "GAGAL INSTALL ULANG: $retryOutput" -ForegroundColor Red
                    exit
                }
            } else {
                Write-Host "GAGAL INSTALL: $installOutput" -ForegroundColor Red
                exit
            }
        } else {
            Write-Host "### UPDATE BERHASIL ($mode mode)! ###" -ForegroundColor Green
        }

        if ($mode -eq "debug") {
            Write-Host "`n[TIPS] Aplikasi siap untuk didebug!" -ForegroundColor Cyan
            Write-Host "Ketik 'flutter attach' di terminal ini untuk melihat LOG." -ForegroundColor White
        }
    } else {
        Write-Host "Gagal menemukan file APK yang cocok untuk mode $mode ($deviceAbi)." -ForegroundColor Red
    }

} catch {
    Write-Host "Terjadi kesalahan sistem: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Bersihkan folder download agar tidak memenuhi disk dan tidak ke-push ke git
    if (Test-Path "release-artifacts") {
        Write-Host "Membersihkan folder sisa download..." -ForegroundColor Gray
        Remove-Item -Recurse -Force "release-artifacts"
    }
    Write-Host "Selesai."
}
