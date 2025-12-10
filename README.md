# Investment Tracker

A personal investment tracking application built with Python, Streamlit, and Poetry.

## Project Structure

```bash
merlin/
├── .github/            # GitHub Actions workflows & config
│   └── workflows/      # CI/CD, CodeQL, and scheduled jobs
├── config/             # Configuration templates
├── data/               # Data persistence (gitignored)
├── src/                # Application source code
│   └── app.py          # Main application entry point
├── tests/              # Test suite
├── .gitignore          # Git ignore rules
├── .markdownlint.json  # Markdownlint configuration
├── .pre-commit-config.yaml # Pre-commit hooks configuration
├── .secrets.baseline   # Detect-secrets baseline file
├── docker-compose.yml  # Docker Compose service definition
├── Dockerfile          # Docker image definition
├── justfile            # Task runner configuration
├── poetry.lock         # Locked dependencies
├── pyproject.toml      # Project configuration and dependencies
└── README.md           # This file
```

## Quality & Security

This project employs a comprehensive suite of tools to ensure high code quality and security standards.

### Static Analysis & Linting

* **[Black](https://github.com/psf/black)**: Uncompromising code formatter.
* **[Ruff](https://github.com/astral-sh/ruff)**: Extremely fast Python linter.
* **[Isort](https://github.com/PyCQA/isort)**: Import sorter.
* **[Mypy](https://github.com/python/mypy)**: Static type checker.
* **[Yamllint](https://github.com/adrienverge/yamllint)**: YAML style and syntax checker.
* **[Markdownlint](https://github.com/DavidAnson/markdownlint-cli2)**: Markdown style checker.

### Security

* **[Semgrep](https://github.com/returntocorp/semgrep)**: Static analysis for security vulnerabilities.
* **[Bandit](https://github.com/PyCQA/bandit)**: Security linter for Python.
* **[Detect Secrets](https://github.com/Yelp/detect-secrets)**: Scans for committed secrets/credentials.
* **[Pip Audit](https://github.com/pypa/pip-audit)**: Audits Python environment for known vulnerabilities.
* **[CodeQL](https://codeql.github.com/)**: GitHub's semantic code analysis engine (Weekly analysis).

### CI/CD

All checks are enforced locally via **pre-commit** and verified in **GitHub Actions**
 (`CI` workflow). A weekly workflow runs deeper security audits.

## Getting Started

### Prerequisites

* Python 3.12+
* Poetry
* Docker & Docker Compose (optional, for containerization)
* `just` task runner (recommended)

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

#### Run Development Server

```bash
just dev
```

The application will be available at `http://localhost:8501`.

#### Run Tests

```bash
just test
```

#### Format & Lint Code

```bash
just format
just lint
```

### Docker Deployment

#### Build & Run

```bash
just docker-run
```

This builds the Docker image and starts the container using Docker Compose. The app will be available at
`http://localhost:8501`.

## Documentation & Comments

All code comments and documentation are provided in English.

## License

[MIT](LICENSE)
