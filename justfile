# Justfile for Investment Tracker

# Prepare the whole development environment
setup: install
    poetry run pre-commit install

# Install dependencies
install:
    poetry install

# Run development server
dev:
    poetry run streamlit run src/app.py

# Run tests
test:
    poetry run pytest

# Run linters and fixers
lint:
    poetry run ruff check src tests
    poetry run mypy src
    poetry run pydocstyle src tests --convention=google

# Format code
format:
    poetry run black .
    poetry run ruff check . --fix
    poetry run isort .

# Build Docker image
docker-build:
    docker compose build

# Run Docker container
docker-run:
    docker compose up
