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
    poetry run detect-secrets scan

# Format code
format:
    poetry run black .
    poetry run ruff check . --fix
    poetry run isort .

# Audit dependencies for vulnerabilities
audit:
    poetry run pip-audit --desc

# Clean up temporary files
clean:
    find . -type f -name "*.pyc" -delete
    find . -type d -name "__pycache__" -delete
    find . -type d -name "*.egg-info" -exec rm -rf {} +
    rm -rf build/
    rm -rf dist/
    rm -rf .pytest_cache/
    rm -rf .mypy_cache/
    rm -rf htmlcov/
    rm -rf site/
    rm -f .coverage
    rm -f coverage.xml
    rm -f pytest-report.xml

# Run cyclomatic complexity check
cc:
    poetry run radon cc src -a -na
    poetry run radon mi src

# Build Docker image
docker-build:
    docker compose build

# Run Docker container
docker-run:
    docker compose up
