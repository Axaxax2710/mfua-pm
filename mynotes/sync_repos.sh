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