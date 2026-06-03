# Makefile для hw2: docker compose + публикация образов на Docker Hub.
#
# ВНИМАНИЕ: этот Makefile — часть задания, его менять НЕ нужно.
# Если кажется, что цель «не работает» — почти наверняка ошибка в
# docker-compose.yml или в env-файлах, а не здесь.
#
# Переменные DOCKERHUB_USERNAME и IMAGE_TAG живут в .env.development.compose:
#   - в build/push-целях подсасываются через `. ./.env.development.compose && ...`
#     (тот же приём, что в hw1 для VITE_API_URL — обрати внимание на $$VAR-экранирование)
#   - в compose-целях передаются флагом `--env-file .env.development.compose`
#     (compose подставит ${DOCKERHUB_USERNAME} и ${IMAGE_TAG} в docker-compose.yml)
#
# Все образы собираются под --platform linux/amd64 — single-arch, чтобы образ
# с твоего Mac M1 запустился на amd64-машине проверяющего.

# ---------- build (локально, под публикацию) ----------

build-back: ## Собрать образ todo-back и протегировать как $IMAGE_TAG и latest
	. ./.env.development.compose && \
	  docker build --platform linux/amd64 \
	    -t $$DOCKERHUB_USERNAME/todo-back:$$IMAGE_TAG \
	    -t $$DOCKERHUB_USERNAME/todo-back:latest \
	    back

build-front: ## Собрать образ todo-front (с VITE_API_URL) и протегировать
	. ./.env.development.compose && . ./.env.development.front && \
	  docker build --platform linux/amd64 \
	    --build-arg "VITE_API_URL=$$VITE_API_URL" \
	    -t $$DOCKERHUB_USERNAME/todo-front:$$IMAGE_TAG \
	    -t $$DOCKERHUB_USERNAME/todo-front:latest \
	    front

build: build-back build-front ## Собрать оба образа

# ---------- push на Docker Hub ----------

push-back: ## Запушить оба тега todo-back
	. ./.env.development.compose && \
	  docker push $$DOCKERHUB_USERNAME/todo-back:$$IMAGE_TAG && \
	  docker push $$DOCKERHUB_USERNAME/todo-back:latest

push-front: ## Запушить оба тега todo-front
	. ./.env.development.compose && \
	  docker push $$DOCKERHUB_USERNAME/todo-front:$$IMAGE_TAG && \
	  docker push $$DOCKERHUB_USERNAME/todo-front:latest

push: push-back push-front ## Запушить оба образа

# ---------- compose lifecycle ----------

pull: ## Скачать образы с Docker Hub (НЕ собирать локально)
	docker compose --env-file .env.development.compose pull
# 	DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose --env-file .env.development.compose pull

up: ## Поднять стек в фоне (compose сам соблюдёт depends_on/healthcheck)
	docker compose --env-file .env.development.compose up -d

down: ## Погасить стек, named volume pgdata сохраняется
	docker compose --env-file .env.development.compose down

down-v: ## Погасить стек + удалить named volume pgdata (сбрасывает БД)
	docker compose --env-file .env.development.compose down -v

logs: ## Стримить логи всех сервисов
	docker compose --env-file .env.development.compose logs -f

ps: ## Показать статус контейнеров
	docker compose --env-file .env.development.compose ps

# ---------- e2e (как в hw1) ----------

e2e-install: ## Один раз: ставит npm-зависимости фронта и качает Chromium для Playwright
	cd front && npm install && npx playwright install --with-deps chromium

e2e: ## Прогнать Playwright-тесты против поднятого стека
	set -a && . ./.env.development.e2e && cd front && npm run e2e
