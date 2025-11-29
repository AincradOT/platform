DOCKER_COMPOSE ?= docker compose

# TODO: Add ANSI
BOLD :=
RED  :=
GREEN :=
YELLOW :=
BLUE :=
RESET :=

setup-windows: ## Set up project dependencies
	@echo No setup command defined for this project.

run-windows: ## Run the project
	@echo No run command defined for this project.

lint-windows: ## Run code linting
	@echo No lint command defined for this project.

format-windows: ## Format code
	@echo No format command defined for this project.

test-windows: ## Run tests
	@echo No test command defined for this project.

build-windows: ## Build the project
	@echo No build command defined for this project.

package-windows: ## Package for release
	@echo No package command defined for this project.

clean-windows: ## Clean up caches, containers, and build artifacts
	@set /p confirm="WARNING: This will remove caches, containers, images, and volumes! This action cannot be undone. Type 'yes' to continue: " && ^
	if not "!confirm!"=="yes" (
		echo Cleanup cancelled. && ^
		exit /b 0
	) && ^
	echo Cleaning up cache and build directories... && ^
	if exist ".pytest_cache" rmdir /s /q ".pytest_cache" 2>nul && ^
	if exist ".mypy_cache" rmdir /s /q ".mypy_cache" 2>nul && ^
	if exist ".ruff_cache" rmdir /s /q ".ruff_cache" 2>nul && ^
	if exist "htmlcov" rmdir /s /q "htmlcov" 2>nul && ^
	if exist "coverage" rmdir /s /q "coverage" 2>nul && ^
	if exist "dist" rmdir /s /q "dist" 2>nul && ^
	if exist "build" rmdir /s /q "build" 2>nul && ^
	if exist "node_modules" rmdir /s /q "node_modules" 2>nul && ^
	echo Removing Python cache files... && ^
	for /d /r . %%%%d in (__pycache__) do if exist "%%%%d" rmdir /s /q "%%%%d" 2>nul && ^
	for /r . %%%%f in (*.pyc) do if exist "%%%%f" del /q "%%%%f" 2>nul && ^
	if exist "$(DOCKER_COMPOSE_FILE)" (
		echo Stopping and removing Docker containers, volumes, and images... && ^
		$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" down -v --rmi all --remove-orphans && ^
		echo Pruning unused Docker resources... && ^
		docker system prune -f
	) else (
		echo No docker-compose.yml found. Skipping Docker cleanup.
	) && ^
	echo Cleanup completed successfully!

up-windows: ## Start Docker services
	@if exist "$(DOCKER_COMPOSE_FILE)" (
		$(DOCKER_COMPOSE) -f "$(DOCKER_COMPOSE_FILE)" up -d
	) else (
		echo No docker-compose.yml found in docker/ && ^
		exit /b 1
	)

help-windows: ## Show available commands
	@echo.
	@echo Available Commands for $(PROJECT_NAME)
	@echo.
	@echo   help          	Show available commands
	@echo   setup         	Set up project dependencies
	@echo   run           	Run the project
	@echo   lint          	Run code linting
	@echo   format        	Format code
	@echo   test          	Run tests
	@echo   build         	Build the project
	@echo   package       	Package for release
	@echo   clean         	Clean up caches, containers, and build artifacts
	@echo   up            	Start Docker services
	@echo.

check-env-windows: ## Check if .env file exists
	@if not exist "$(ENV_FILE)" (
		echo ERROR: No .env file found. && ^
		echo. && ^
		if exist ".env.example" (
			echo Run the following command to create it: && ^
			echo     copy .env.example .env
		) else (
			echo Create an empty one: && ^
			echo     type NUL ^> .env
		) && ^
		echo. && ^
		echo After creating the .env file, update the values inside it before continuing. && ^
		exit /b 1
	)
