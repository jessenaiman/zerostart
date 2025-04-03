"""
ZeroStart Demo Module with Type Validation
"""

from typing import Annotated
from pydantic import BaseModel, Field

class ProjectStatus(BaseModel):
    """Demonstrate Pydantic validation"""
    ci_passing: Annotated[bool, Field(description="CI pipeline status")]
    lint_score: Annotated[int, Field(ge=0, le=100)]

def run_example() -> str:
    """Main demo function"""
    # Deliberate temporary violation (fix in CI):
    status = ProjectStatus(ci_passing=True, lint_score=101)
    
    return f"""
    ZeroStart Status:
    - CI Passing: {status.ci_passing}
    - Lint Score: {status.lint_score}/100
    """

if __name__ == "__main__":
    print(run_example())