[file name]: scripts/requirements_txt/generate_requirements.py
[file content begin]
"""
Generates requirements.txt from Poetry setup for AI compatibility
"""
import subprocess

def main():
    try:
        subprocess.run(
            ["poetry", "export", "-f", "requirements.txt", "--output", "requirements.txt", "--without-hashes"],
            check=True
        )
        print("✓ Generated requirements.txt from Poetry")
    except Exception as e:
        print(f"⚠ Couldn't generate from Poetry: {str(e)}")
        print("✓ Using fallback requirements.txt")

if __name__ == "__main__":
    main()
[file content end]