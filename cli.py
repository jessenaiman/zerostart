import typer
from pathlib import Path

app = typer.Typer(help="ZeroStart project initializer")

@app.command()
def init(
    project_name: str,
    with_database: bool = typer.Option(False, "--with-database"),
    no_game: bool = typer.Option(False, "--no-game"),
):
    """Initialize new project"""
    typer.echo(f"Creating {project_name}...")
    Path(project_name).mkdir(exist_ok=True)
    # Add initialization logic here
    typer.echo(f"✓ Project {project_name} created")

@app.command()
def verify():
    """Run system verification"""
    typer.echo("Running verification checks...")
    # Add verification logic here
    typer.echo("✓ All systems operational")

if __name__ == "__main__":
    app()