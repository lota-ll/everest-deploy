#!/bin/bash
# ============================================================================
# EVerest Deployment Script for Cyber Range
# Сервер: 172.16.0.40
# Підключення до CitrineOS: 192.168.20.20:8092
# ============================================================================

set -e

echo "=============================================="
echo "EVerest OCPP 1.6 Deployment Script"
echo "=============================================="

# 1. Перевірка Docker
echo ""
echo "[1/5] Перевірка Docker..."
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker не встановлено. Встановлюю..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo apt install -y docker-compose-plugin
    sudo usermod -aG docker $USER
    echo ""
    echo "❗ Docker встановлено. Будь ласка:"
    echo "   1. Вийдіть з сесії: exit"
    echo "   2. Зайдіть знову"
    echo "   3. Запустіть цей скрипт повторно"
    exit 0
fi
echo "✅ Docker встановлено"

# 2. Перевірка з'єднання з CitrineOS
echo ""
echo "[2/5] Перевірка з'єднання з CitrineOS (192.168.20.20:8092)..."
if nc -zw3 192.168.20.20 8092 2>/dev/null; then
    echo "✅ CitrineOS доступний"
else
    echo "⚠️  Не вдається з'єднатися з CitrineOS на 192.168.20.20:8092"
    echo "   Перевірте:"
    echo "   - Чи запущено CitrineOS на сервері 192.168.20.20"
    echo "   - Чи відкрито порт 8092 на фаєрволі"
    echo "   - Чи є мережеве з'єднання між серверами"
    read -p "   Продовжити все одно? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 3. Перевірка файлів
echo ""
echo "[3/5] Перевірка файлів..."
MISSING=0
for file in docker-compose.yml Dockerfile config-docker.json my-config.yaml start.sh .env; do
    if [ ! -f "$file" ]; then
        echo "❌ $file не знайдено!"
        MISSING=1
    fi
done
if [ $MISSING -eq 1 ]; then
    echo "❌ Деякі файли відсутні. Перевірте директорію."
    exit 1
fi
echo "✅ Всі файли на місці"

# 4. Встановлення прав на start.sh
echo ""
echo "[4/5] Встановлення прав доступу..."
chmod +x start.sh
echo "✅ Права встановлено"

# 5. Запуск
echo ""
echo "[5/5] Запуск EVerest..."
docker compose up -d --build

# Очікування запуску
echo ""
echo "Очікування запуску контейнерів..."
sleep 30

# Статус
echo ""
echo "=============================================="
echo "Статус контейнерів:"
echo "=============================================="
docker compose ps
echo ""

# Перевірка логів manager
echo "=============================================="
echo "Логи EVerest Manager (останні 20 рядків):"
echo "=============================================="
docker logs everest-manager --tail 20 2>&1 || true
echo ""

echo "=============================================="
echo "✅ РОЗГОРТАННЯ ЗАВЕРШЕНО!"
echo "=============================================="
echo ""
echo "Доступні сервіси:"
echo "  • EVerest UI:    http://172.16.0.40:1880/ui/"
echo "  • NodeRed:       http://172.16.0.40:1880/"
echo "  • OCPP Logs:     http://172.16.0.40:8888/"
echo ""
echo "Налаштування підключення:"
echo "  • ChargePointId: CP001"
echo "  • CSMS URL:      ws://192.168.20.20:8092/CP001"
echo "  • Протокол:      OCPP 1.6"
echo ""
echo "Корисні команди:"
echo "  docker compose logs -f manager   # Логи EVerest"
echo "  docker compose down              # Зупинити"
echo "  docker compose up -d             # Запустити"
echo ""
