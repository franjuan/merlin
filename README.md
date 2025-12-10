# Investment Tracker

A personal investment tracking application built with Python, Streamlit, and Poetry.

## Project Structure

```bash
merlin/
├── config/             # Configuration templates
├── data/               # Data persistence (gitignored)
├── src/                # Application source code
│   └── app.py          # Main application entry point
├── tests/              # Test suite
├── .gitignore          # Git ignore rules
├── .pre-commit-config.yaml # Pre-commit hooks
├── docker-compose.yml  # Docker Compose service definition
├── Dockerfile          # Docker image definition
├── justfile            # Task runner configuration
├── poetry.lock         # Locked dependencies
├── pyproject.toml      # Project configuration and dependencies
└── README.md           # This file
```

## Getting Started

### Prerequisites

- Python 3.12+
- Poetry
- Docker & Docker Compose (optional, for containerization)
- `just` task runner (recommended)

### Installation

1. **Clone the repository**

    ```bash
    git clone <repository_url>
    cd merlin
    ```

2. **Setup environment**

    This command installs dependencies and pre-commit hooks.

    ```bash
    just setup
    ```

3. **Configure application**

    Copy the example configuration files.

    ```bash
    cp config/example.env config/.env
    cp config/example.yaml config/config.yaml
    ```

### Usage

**Run Development Server**

```bash
just dev
```

The application will be available at `http://localhost:8501`.

**Run Tests**

```bash
just test
```

**Format & Lint Code**

```bash
just format
just lint
```

### Docker Deployment

**Build & Run**

```bash
just docker-run
```

This builds the Docker image and starts the container using Docker Compose. The app will be available at `http://localhost:8501`.

## Documentation & Comments

All code comments and documentation are provided in English.

## License

[MIT](LICENSE)
