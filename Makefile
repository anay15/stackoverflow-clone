.PHONY: setup dev migrate seeds clean test

# Setup the entire project
setup:
	@echo "Setting up Stack Overflow Clone..."
	@cp env.example .env
	@echo "Created .env file from template"
	@echo "Building Docker images..."
	@docker compose build
	@echo "Installing frontend dependencies..."
	@docker compose run --rm frontend npm install
	@echo "Running database migrations..."
	@docker compose run --rm web mix ecto.create
	@docker compose run --rm web mix ecto.migrate
	@echo "Setup complete! Run 'make dev' to start the application."

# Start development environment
dev:
	@echo "Starting development environment..."
	@docker compose up --build

# Run database migrations
migrate:
	@echo "Running database migrations..."
	@docker compose run --rm web mix ecto.migrate

# Seed the database
seeds:
	@echo "Seeding database..."
	@docker compose run --rm web mix run priv/repo/seeds.exs

# Clean up containers and volumes
clean:
	@echo "Cleaning up..."
	@docker compose down -v
	@docker system prune -f

# Run tests
test:
	@echo "Running backend tests..."
	@docker compose run --rm web mix test
	@echo "Running frontend tests..."
	@docker compose run --rm frontend npm test -- --watchAll=false

# Install dependencies without Docker
install-deps:
	@echo "Installing backend dependencies..."
	@cd backend && mix deps.get
	@echo "Installing frontend dependencies..."
	@cd frontend && npm install

# Run without Docker (requires local Elixir, Node, and Postgres)
run-local:
	@echo "Starting local development..."
	@cd backend && mix phx.server &
	@cd frontend && npm start

# Stop all services
stop:
	@docker compose down
