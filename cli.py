import typer
from pathlib import Path

app = typer.Typer()

@app.command()
def init(project_name: str):
    """Initialize new project"""
    print(f"Creating {project_name}...")
    # Add your initialization logic here
    print(f"✓ Project {project_name} ready!\n")
    print("Next steps:")
    print(f"cd {project_name}")
    print("poetry install")

@app.command()
def clean():
    """Remove generated files"""
    print("Cleaning project...")
    # Add cleanup logic
    print("✓ Project reset")

if __name__ == "__main__":
    app()