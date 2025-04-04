#!/usr/bin/env python3
"""
Docstring Protection Script for ZeroStart Projects

This script helps prevent AI coding tools from removing or modifying docstrings by:
1. Creating docstring inventory and saving it for comparison
2. Validating that docstrings haven't been removed or degraded
3. Integrating with pre-commit hooks for docstring protection

Usage:
  python protect_docstrings.py inventory  # Create inventory
  python protect_docstrings.py validate   # Validate against inventory
  python protect_docstrings.py install    # Set up pre-commit hook
"""

import argparse
import ast
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional


INVENTORY_FILE = ".docstring_inventory.json"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"  # No Color
CHECK = "✓"
CROSS = "❌"
WARNING = "⚠️"


class DocstringVisitor(ast.NodeVisitor):
    """AST visitor that collects docstrings from Python modules."""
    
    def __init__(self):
        self.docstrings = {}
        self.current_path = []
    
    def visit_Module(self, node):
        """Visit a module node and collect its docstring."""
        if ast.get_docstring(node):
            self.docstrings['.'.join(['module'])] = ast.get_docstring(node)
        self.generic_visit(node)
    
    def visit_ClassDef(self, node):
        """Visit a class definition and collect its docstring."""
        self.current_path.append(node.name)
        if ast.get_docstring(node):
            self.docstrings['.'.join(self.current_path)] = ast.get_docstring(node)
        self.generic_visit(node)
        self.current_path.pop()
    
    def visit_FunctionDef(self, node):
        """Visit a function definition and collect its docstring."""
        self.current_path.append(node.name)
        if ast.get_docstring(node):
            self.docstrings['.'.join(self.current_path)] = ast.get_docstring(node)
        self.generic_visit(node)
        self.current_path.pop()
    
    def visit_AsyncFunctionDef(self, node):
        """Visit an async function definition and collect its docstring."""
        self.current_path.append(node.name)
        if ast.get_docstring(node):
            self.docstrings['.'.join(self.current_path)] = ast.get_docstring(node)
        self.generic_visit(node)
        self.current_path.pop()


def collect_docstrings(file_path: Path) -> Dict[str, str]:
    """Collect all docstrings from a Python file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        tree = ast.parse(content)
        visitor = DocstringVisitor()
        visitor.visit(tree)
        return visitor.docstrings
    except SyntaxError:
        print(f"{RED}{CROSS} Syntax error in {file_path}{NC}")
        return {}
    except Exception as e:
        print(f"{RED}{CROSS} Error processing {file_path}: {e}{NC}")
        return {}


def find_python_files(start_dir: Path) -> List[Path]:
    """Find all Python files in the given directory and its subdirectories."""
    return list(start_dir.glob('**/*.py'))


def create_inventory(src_dir: Path) -> Dict[str, Dict[str, str]]:
    """Create a docstring inventory from all Python files in src_dir."""
    print(f"{YELLOW}Creating docstring inventory...{NC}")
    inventory = {}
    
    python_files = find_python_files(src_dir)
    if not python_files:
        print(f"{YELLOW}{WARNING} No Python files found in {src_dir}{NC}")
        return inventory
    
    for file_path in python_files:
        relative_path = file_path.relative_to(src_dir)
        docstrings = collect_docstrings(file_path)
        if docstrings:
            inventory[str(relative_path)] = docstrings
    
    return inventory


def save_inventory(inventory: Dict[str, Dict[str, str]], output_file: Path) -> None:
    """Save the docstring inventory to a JSON file."""
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(inventory, f, indent=2)
    print(f"{GREEN}{CHECK} Docstring inventory saved to {output_file}{NC}")
    print(f"Found {sum(len(docstrings) for docstrings in inventory.values())} docstrings in {len(inventory)} files.")


def load_inventory(inventory_file: Path) -> Dict[str, Dict[str, str]]:
    """Load a docstring inventory from a JSON file."""
    try:
        with open(inventory_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"{RED}{CROSS} Inventory file not found: {inventory_file}{NC}")
        return {}
    except json.JSONDecodeError:
        print(f"{RED}{CROSS} Invalid JSON in inventory file: {inventory_file}{NC}")
        return {}


def validate_docstrings(
    src_dir: Path, 
    inventory: Dict[str, Dict[str, str]]
) -> Tuple[bool, List[str]]:
    """Validate docstrings against the inventory."""
    print(f"{YELLOW}Validating docstrings against inventory...{NC}")
    
    if not inventory:
        print(f"{YELLOW}{WARNING} Empty inventory, nothing to validate against{NC}")
        return False, ["Empty inventory"]
    
    all_valid = True
    issues = []
    
    for rel_path_str, expected_docstrings in inventory.items():
        rel_path = Path(rel_path_str)
        full_path = src_dir / rel_path
        
        if not full_path.exists():
            print(f"{YELLOW}{WARNING} File no longer exists: {rel_path}{NC}")
            continue
        
        current_docstrings = collect_docstrings(full_path)
        
        for path, expected in expected_docstrings.items():
            if path not in current_docstrings:
                all_valid = False
                issue = f"Missing docstring: {rel_path}:{path}"
                print(f"{RED}{CROSS} {issue}{NC}")
                issues.append(issue)
            elif current_docstrings[path] != expected:
                if len(current_docstrings[path]) < len(expected) * 0.8:  # 80% threshold
                    all_valid = False
                    issue = f"Degraded docstring: {rel_path}:{path}"
                    print(f"{RED}{CROSS} {issue}{NC}")
                    issues.append(issue)
    
    if all_valid:
        print(f"{GREEN}{CHECK} All docstrings are valid{NC}")
    
    return all_valid, issues


def create_precommit_hook() -> None:
    """Create a pre-commit hook configuration for docstring protection."""
    hook_config = """
# Add this to your .pre-commit-config.yaml
- repo: local
  hooks:
    - id: protect-docstrings
      name: Protect Docstrings
      entry: python scripts/protect_docstrings.py validate
      language: system
      pass_filenames: false
      always_run: true
"""
    print(f"{YELLOW}Add this to your .pre-commit-config.yaml file:{NC}")
    print(hook_config)
    
    # Check if .pre-commit-config.yaml exists
    if os.path.exists('.pre-commit-config.yaml'):
        print(f"{YELLOW}Found existing .pre-commit-config.yaml{NC}")
        print(f"{YELLOW}Please manually add the hook configuration above.{NC}")
    else:
        print(f"{YELLOW}.pre-commit-config.yaml not found{NC}")
        print(f"{YELLOW}Create it and add the hook configuration above.{NC}")


def install_hook_script() -> None:
    """Install the docstring protection hook script."""
    hooks_dir = Path('.git/hooks')
    if not hooks_dir.exists():
        print(f"{RED}{CROSS} .git directory not found. Initialize git first.{NC}")
        return
    
    hooks_dir.mkdir(exist_ok=True)
    hook_path = hooks_dir / 'pre-commit'
    
    hook_content = """#!/bin/sh
# Pre-commit hook for docstring protection
python scripts/protect_docstrings.py validate || exit 1
"""
    
    with open(hook_path, 'w') as f:
        f.write(hook_content)
    
    # Make executable
    os.chmod(hook_path, 0o755)
    print(f"{GREEN}{CHECK} Installed pre-commit hook at {hook_path}{NC}")


def setup_coverage_check() -> None:
    """Set up docstring coverage checking with interrogate."""
    try:
        import subprocess
        
        # Check if interrogate is installed
        try:
            subprocess.run(['interrogate', '--version'], check=True, capture_output=True)
            print(f"{GREEN}{CHECK} interrogate is already installed{NC}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print(f"{YELLOW}Installing interrogate...{NC}")
            subprocess.run(['pip', 'install', 'interrogate'], check=True)
            print(f"{GREEN}{CHECK} interrogate installed successfully{NC}")
        
        # Create interrogate configuration
        pyproject_path = Path('pyproject.toml')
        if pyproject_path.exists():
            with open(pyproject_path, 'r') as f:
                content = f.read()
            
            if '[tool.interrogate]' not in content:
                with open(pyproject_path, 'a') as f:
                    f.write('\n[tool.interrogate]\n')
                    f.write('ignore-init-method = true\n')
                    f.write('ignore-init-module = true\n')
                    f.write('ignore-magic = false\n')
                    f.write('ignore-semiprivate = false\n')
                    f.write('ignore-private = false\n')
                    f.write('ignore-module = false\n')
                    f.write('ignore-nested-functions = false\n')
                    f.write('ignore-nested-classes = false\n')
                    f.write('fail-under = 80\n')  # 80% coverage required
                print(f"{GREEN}{CHECK} Added interrogate configuration to pyproject.toml{NC}")
        else:
            with open(pyproject_path, 'w') as f:
                f.write('[tool.interrogate]\n')
                f.write('ignore-init-method = true\n')
                f.write('ignore-init-module = true\n')
                f.write('ignore-magic = false\n')
                f.write('ignore-semiprivate = false\n')
                f.write('ignore-private = false\n')
                f.write('ignore-module = false\n')
                f.write('ignore-nested-functions = false\n')
                f.write('ignore-nested-classes = false\n')
                f.write('fail-under = 80\n')  # 80% coverage required
            print(f"{GREEN}{CHECK} Created pyproject.toml with interrogate configuration{NC}")
        
        print(f"{GREEN}{CHECK} Docstring coverage check setup complete{NC}")
        print(f"{YELLOW}Run 'interrogate src/' to check docstring coverage{NC}")
        
    except Exception as e:
        print(f"{RED}{CROSS} Error setting up coverage check: {e}{NC}")


def main() -> None:
    """Main entry point for the docstring protection script."""
    parser = argparse.ArgumentParser(description='Protect docstrings from AI removal')
    subparsers = parser.add_subparsers(dest='command', help='Command to run')
    
    # Inventory command
    inventory_parser = subparsers.add_parser('inventory', help='Create docstring inventory')
    inventory_parser.add_argument('--src', type=str, default='src', help='Source directory')
    inventory_parser.add_argument('--output', type=str, default=INVENTORY_FILE, help='Output file')
    
    # Validate command
    validate_parser = subparsers.add_parser('validate', help='Validate docstrings against inventory')
    validate_parser.add_argument('--src', type=str, default='src', help='Source directory')
    validate_parser.add_argument('--inventory', type=str, default=INVENTORY_FILE, help='Inventory file')
    
    # Install command
    subparsers.add_parser('install', help='Install pre-commit hook')
    
    # Setup coverage command
    subparsers.add_parser('setup-coverage', help='Setup docstring coverage checking')
    
    args = parser.parse_args()
    
    if args.command == 'inventory':
        src_dir = Path(args.src)
        if not src_dir.exists():
            print(f"{RED}{CROSS} Source directory not found: {src_dir}{NC}")
            return
        
        inventory = create_inventory(src_dir)
        save_inventory(inventory, Path(args.output))
    
    elif args.command == 'validate':
        src_dir = Path(args.src)
        if not src_dir.exists():
            print(f"{RED}{CROSS} Source directory not found: {src_dir}{NC}")
            return
        
        inventory = load_inventory(Path(args.inventory))
        is_valid, _ = validate_docstrings(src_dir, inventory)
        if not is_valid:
            sys.exit(1)
    
    elif args.command == 'install':
        create_precommit_hook()
        install_hook_script()
    
    elif args.command == 'setup-coverage':
        setup_coverage_check()
    
    else:
        parser.print_help()


if __name__ == '__main__':
    main()