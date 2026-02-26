

# Bash-прикладной скрипт (Linux/WSL)
## Назначение:
- Переключается в корневую директорию пользователя (или другой корень, заданный переменной).
- Выполняет `git pull` в указанном локальном репозитории (репозиторий-источник).
- Копирует все содержимое репозитория-источника в локальный репозиторий-назначение, исключая директорию `.git` и проверяя корректность путей.
- Заменяет существующие файлы и папки в назначении.

Файл: `sync_repos.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail

# Настройки
USER_HOME="${HOME:-/root}"
SOURCE_REPO="$USER_HOME/source_repo"   # локальный путь к исходному репозиторию
DEST_REPO="$USER_HOME/dest_repo"       # локальный путь к целевому репозиторию
LOG_FILE="${USER_HOME}/sync_repos.log"

# Функции
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
}

die() {
  log "FATAL: $*"
  exit 1
}

# Валидация путей
for p in "$SOURCE_REPO" "$DEST_REPO"; do
  [ -d "$p" ] || die "Директория не найдена: $p"
  [ -d "$p/.git" ] || true  # позволяем репозиторию без .git на момент проверки
done

# Проверка git-активности в SOURCE_REPO
if [ -d "$SOURCE_REPO/.git" ]; then
  pushd "$SOURCE_REPO" >/dev/null || die "Не удаётся перейти в $SOURCE_REPO"
  # Пропуск приватности: предполагаем, что ключи/кэш настроены
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    popd >/dev/null
    die "SOURCE_REPO не является git-рабочей копией"
  fi
  log "Запуск git pull в $SOURCE_REPO"
  git pull || die "git pull в $SOURCE_REPO не удался"
  popd >/dev/null
else
  die "SOURCE_REPO не содержит .git: $SOURCE_REPO"
fi

# Копирование содержимого из SOURCE_REPO в DEST_REPO, исключая .git
log "Копирование содержимого из $SOURCE_REPO в $DEST_REPO (за исключением .git)..."
rsync -a --delete \
  --exclude='.git' \
  "$SOURCE_REPO/" "$DEST_REPO/" \
  || die "Ошибка копирования через rsync"

log "Синхронизация завершена успешно."
exit 0
```

## Как использовать:
- Отредактируйте переменные `SOURCE_REPO` и `DEST_REPO` в скрипте, указав реальные пути к вашим репозиториям.
- Сделайте скрипт исполняемым:  
  ```bash
  chmod +x sync_repos.sh
  ```
- Запустите через терминал:  
  ```bash
  ./sync_repos.sh
  ```
- При необходимости можно передать пути через переменные окружения (например, `export SOURCE_REPO=/custom/path`), предварительно изменив скрипт так, чтобы они читались из окружения (как в версии с параметрами).

---

# PowerShell-скрипт (Windows, через Git Bash/Cygwin/PowerShell)
## Назначение:
- Аналогично Bash-версии: обновление локального репозитория-источника, копирование содержимого в назначение, исключая папку `.git`.

Файл: `sync_repos.ps1`
```powershell
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
```

## Как использовать:
- Требуется PowerShell 5+ (Windows) или PowerShell 7+ (кросс-платформенный).
- Разрешите выполнение скриптов (если ещё не сделано):  
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```
- Запустите с указанием путей:  
  ```powershell
  .\sync_repos.ps1 -Source D:\Projects\myapp -Destination D:\Backups\myapp_copy
  ```
- Если параметры не указаны, используются значения по умолчанию (`%USERPROFILE%\source_repo` и `%USERPROFILE%\dest_repo`).

## Общие рекомендации
- Для автоматического запуска можно добавить скрипт в планировщик задач (Windows) или через cron/systemd (Linux/WSL).
- Убедитесь, что для приватных репозиториев настроена аутентификация (SSH-ключи или сохранённые пароли).
- При копировании через `rsync` (Linux) и `robocopy` (Windows) сохраняются права доступа и метаданные (где это возможно).