<#
.SYNOPSIS
    Синхронизирует два локальных git-репозитория.
.DESCRIPTION
    Выполняет git pull в исходном репозитории и копирует все файлы (кроме .git) в целевой репозиторий.
    Пути задаются параметрами -Source и -Destination.
.PARAMETER Source
    Полный путь к исходному репозиторию.
.PARAMETER Destination
    Полный путь к целевому репозиторию.
.PARAMETER LogFile
    Путь к файлу лога (по умолчанию: ~\sync_repos.log).
.EXAMPLE
    .\sync_repos.ps1 -Source D:\Projects\myapp -Destination D:\Backups\myapp_copy
#>

param(
  [string]$Source,
  [string]$Destination,
  [string]$LogFile = "$env:USERPROFILE\sync_repos.log"
)

# Если параметры не заданы, используем значения по умолчанию
if (-not $Source) { $Source = "$env:USERPROFILE\source_repo" }
if (-not $Destination) { $Destination = "$env:USERPROFILE\dest_repo" }

function Write-Log {
  param([string]$Message)
  $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
  Write-Output $line
  Add-Content -Path $LogFile -Value $line
}

# Проверка путей
foreach ($p in @($Source, $Destination)) {
  if (-not (Test-Path $p)) {
    Write-Log "Директория не найдена: $p"
    exit 1
  }
}

# Обновление исходного репозитория
if (Test-Path (Join-Path $Source ".git")) {
  Push-Location $Source
  Write-Log "Выполнение git pull в $Source"
  $pull = git pull 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Log "git pull вернул ошибку: $pull"
    Pop-Location
    exit 1
  }
  Pop-Location
} else {
  Write-Log "Исходный репозиторий не содержит .git: $Source"
  exit 1
}

# Копирование содержимого из Source в Destination, исключая .git
Write-Log "Начало копирования содержимого из $Source в $Destination, исключая .git"

# Подготовка путей для robocopy (с завершающим слэшем)
$src = if ($Source.EndsWith('\')) { $Source } else { "$Source\" }
$dst = if ($Destination.EndsWith('\')) { $Destination } else { "$Destination\" }

$robocopyArgs = @($src, $dst, "/MIR", "/XD", ".git")
$result = robocopy @robocopyArgs

# robocopy возвращает код завершения; 0-7 – успех (см. документацию)
if ($LASTEXITCODE -ge 8) {
  Write-Log "Robocopy завершился с ошибкой (код $LASTEXITCODE)"
  exit 1
}

Write-Log "Синхронизация завершена. Robocopy код: $LASTEXITCODE"
exit 0