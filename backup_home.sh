#!/bin/bash

# Скрипт резервного копирования домашней директории пользователя dz
# Автор: dz
# Дата: $(date)

# Переменные
SOURCE_DIR="/home/dz/"
BACKUP_DIR="/tmp/backup"
LOG_FILE="/tmp/backup.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Проверка существования исходной директории
if [ ! -d "$SOURCE_DIR" ]; then
    echo "$TIMESTAMP - ОШИБКА: Исходная директория $SOURCE_DIR не существует" | tee -a $LOG_FILE
    logger "backup_home: ОШИБКА - исходная директория не существует"
    exit 1
fi

# Создание директории для бэкапа, если её нет
if [ ! -d "$BACKUP_DIR" ]; then
    echo "$TIMESTAMP - Создание директории $BACKUP_DIR" | tee -a $LOG_FILE
    sudo mkdir -p "$BACKUP_DIR"
    sudo chown dz:dz "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "$TIMESTAMP - ОШИБКА: Не удалось создать директорию $BACKUP_DIR" | tee -a $LOG_FILE
        logger "backup_home: ОШИБКА - не удалось создать директорию"
        exit 1
    fi
fi

# Выполнение резервного копирования
echo "$TIMESTAMP - Начало резервного копирования" | tee -a $LOG_FILE
logger "backup_home: Начало резервного копирования"

rsync -avzh --delete --checksum --exclude='.*' "$SOURCE_DIR" "$BACKUP_DIR" >> $LOG_FILE 2>&1

# Проверка результата
if [ $? -eq 0 ]; then
    echo "$TIMESTAMP - УСПЕХ: Резервное копирование завершено успешно" | tee -a $LOG_FILE
    logger "backup_home: УСПЕХ - резервное копирование завершено"
    # Дополнительная информация о размере бэкапа
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
    echo "$TIMESTAMP - Информация: Размер бэкапа $BACKUP_SIZE" | tee -a $LOG_FILE
else
    echo "$TIMESTAMP - ОШИБКА: Резервное копирование завершилось с ошибкой" | tee -a $LOG_FILE
    logger "backup_home: ОШИБКА - резервное копирование завершилось с ошибкой"
    exit 1
fi

echo "$TIMESTAMP - Конец выполнения скрипта" | tee -a $LOG_FILE
echo "----------------------------------------" | tee -a $LOG_FILE

exit 0