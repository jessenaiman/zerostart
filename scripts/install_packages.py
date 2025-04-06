import importlib
import os
import subprocess
import sys

from pydantic import BaseModel, Field, ValidationError


class PackageConfig(BaseModel):
    """Configuration model for package installation settings."""

    packages: list[str] = Field(..., description="List of package names to install")

    class Config:
        """Pydantic configuration settings."""

        extra = "forbid"  # Disallow extra fields


class PackageInstaller:
    """Manages the installation and verification of Python packages.

    Attributes:
        config: PackageConfig object containing the list of packages to install.
    """

    def __init__(self, packages: list[str]) -> None:
        """Initialize the PackageInstaller with a list of packages.

        Args:
            packages: List of package names to install and verify.

        Raises:
            SystemExit: If virtual environment is not active or config validation fails.
        """
        self._check_virtual_env()
        try:
            self.config = PackageConfig(packages=packages)
        except ValidationError as e:
            print(f"❌ Configuration error: {e}")
            sys.exit(1)

    def _check_virtual_env(self) -> None:
        """Verify that a virtual environment is active.

        Raises:
            SystemExit: If VIRTUAL_ENV environment variable is not set.
        """
        if "VIRTUAL_ENV" not in os.environ:
            print(
                "❌ Virtual environment not activated. Please run "
                "'source .venv/Scripts/activate' (Windows) or "
                "'source .venv/bin/activate' (Linux/MacOS) first."
            )
            sys.exit(1)

    def install_and_verify_package(self, package: str) -> None:
        """Install a package using pip and verify its installation.

        Args:
            package: Name of the package to install.

        Raises:
            SystemExit: If installation or verification fails.
        """
        print(f"Installing {package}...")
        try:
            subprocess.run(
                [
                    sys.executable,
                    "-m",
                    "pip",
                    "install",
                    package,
                    "--root-user-action=ignore",
                ],
                check=True,
                capture_output=True,
                text=True,
            )
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to install {package}: {e.stderr}")
            sys.exit(1)

        print(f"Verifying {package} installation...")
        try:
            importlib.import_module(package)
            print(f"✓ {package} imported successfully")
        except ImportError as e:
            print(f"❌ Failed to import {package}: {e}")
            sys.exit(1)

        print(f"Package details for {package}:")
        try:
            result = subprocess.run(
                [sys.executable, "-m", "pip", "show", package],
                check=True,
                capture_output=True,
                text=True,
            )
            print(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to show details for {package}: {e.stderr}")
            sys.exit(1)
        print("----------------------------------------")

    def run(self) -> None:
        """Execute the installation and verification process for all packages."""
        for package in self.config.packages:
            self.install_and_verify_package(package)
        print("✓ All packages processed successfully")


def main() -> None:
    """Entry point for the script.

    Raises:
        SystemExit: If no packages are provided or processing fails.
    """
    if len(sys.argv) < 2:
        print("❌ No packages specified. Usage: python install_packages.py package1")
        sys.exit(1)

    installer = PackageInstaller(sys.argv[1:])
    installer.run()


if __name__ == "__main__":
    main()
