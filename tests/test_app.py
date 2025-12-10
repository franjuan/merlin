from src.app import main


def test_app_import() -> None:
    """Test that the app module can be imported and main function exists."""
    assert callable(main)
