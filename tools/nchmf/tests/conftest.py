import sys
from pathlib import Path

# Scripts live one level up and are run directly, not installed as a package.
sys.path.insert(0, str(Path(__file__).parents[1]))
