#!/usr/bin/env python3
"""
Documentation Hook for JARVIS

Validates markdown file structure follows the approved documentation plan.

Allowed MD Structure:
- CLAUDE.md        (Project instructions for Claude Code)
- CHANGELOG.md     (Version history)
- README.md        (Project overview)
- jarvis/**/README.md (Module-specific docs, optional)

Forbidden/Temporary:
- PLAN*.md         (Should be deleted after feature completion)
- CONTEXT*.md      (Superseded by CLAUDE.md)
- *_PLAN.md        (Migration/refactoring plans - one-time use)
- *_PROMPT.md      (One-time prompts)
"""

import sys
from pathlib import Path
from typing import List

hooks_dir = Path(__file__).parent
sys.path.insert(0, str(hooks_dir))

try:
    from .master_hook import BaseHook, HookResult, HookStatus
except ImportError:
    from master_hook import BaseHook, HookResult, HookStatus


class DocumentationHook(BaseHook):
    """
    Validates markdown documentation structure.

    Checks:
    - Essential files exist (CLAUDE.md, CHANGELOG.md, README.md)
    - No temporary PLAN*.md files lingering
    - No outdated context files
    - Module READMEs are in appropriate locations
    """

    name = "Documentation"
    description = "Validates markdown file structure"
    blocking_on_failure = False  # Warnings only, not blocking

    # Essential files that MUST exist at project root
    REQUIRED_FILES = [
        "CLAUDE.md",
        "CHANGELOG.md",
    ]

    # Recommended files (warning if missing, not blocking)
    RECOMMENDED_FILES = [
        "README.md",
    ]

    # Allowed markdown files at project root
    ALLOWED_ROOT_FILES = {
        "CLAUDE.md",
        "CHANGELOG.md",
        "README.md",
        "LICENSE.md",
        "CONTRIBUTING.md",
        "SECURITY.md",
    }

    # Patterns that indicate temporary/plan files (should be cleaned up)
    TEMPORARY_PATTERNS = [
        "PLAN",           # PLAN.md, PLAN-*.md
        "CONTEXT",        # CONTEXT.md, context_state.md
        "_PLAN.md",       # MIGRATION_PLAN.md, REFACTORING_PLAN.md
        "_PROMPT.md",     # STATEMENTS_UPGRADE_PROMPT.md
    ]

    # Directories where README.md is allowed
    ALLOWED_README_DIRS = [
        "jarvis",
        "jarvis/core",
        "jarvis/core/connectors",
        "jarvis/core/connectors/efactura",
        "jarvis/accounting",
        "jarvis/hr",
        "hooks",
    ]

    # Directories to skip (generated/cache)
    SKIP_DIRS = {
        ".git",
        ".claude-code",
        ".pytest_cache",
        ".playwright-mcp",
        "node_modules",
        "__pycache__",
        "venv",
        "backups",
    }

    def run(self) -> HookResult:
        """Run documentation structure validation."""
        details: List[str] = []
        warnings: List[str] = []

        # Find all markdown files
        all_md_files = self._find_markdown_files()
        details.append(f"Found {len(all_md_files)} markdown files")

        # Check required files exist
        missing = self._check_required_files()
        if missing:
            return self._create_result(
                HookStatus.FAILED,
                f"Missing required documentation: {', '.join(missing)}",
                [f"Create missing file: {f}" for f in missing],
            )

        # Check recommended files
        missing_recommended = self._check_recommended_files()
        for f in missing_recommended:
            warnings.append(f"Recommended file missing: {f}")

        # Check for temporary/plan files that should be cleaned up
        temp_files = self._find_temporary_files(all_md_files)
        for f in temp_files:
            warnings.append(f"Temporary file should be cleaned up: {f}")

        # Check for unexpected root-level markdown files
        unexpected = self._find_unexpected_root_files(all_md_files)
        for f in unexpected:
            warnings.append(f"Unexpected root MD file: {f} (move to docs/ or delete)")

        # Check README.md locations
        misplaced = self._check_readme_locations(all_md_files)
        for f in misplaced:
            warnings.append(f"README.md in unexpected location: {f}")

        if warnings:
            return self._create_result(
                HookStatus.WARNING,
                f"Found {len(warnings)} documentation structure issues",
                warnings[:10] + (["... and more"] if len(warnings) > 10 else []),
            )

        details.append("All required files present")
        details.append("No temporary plan files found")
        details.append("Documentation structure is clean")

        return self._create_result(
            HookStatus.PASSED,
            "Documentation structure validated",
            details,
        )

    def _find_markdown_files(self) -> List[Path]:
        """Find all markdown files, excluding skip directories."""
        md_files = []

        for md_file in self.target_path.parent.rglob("*.md"):
            # Check if file is in a skip directory
            parts = md_file.parts
            if any(skip in parts for skip in self.SKIP_DIRS):
                continue
            md_files.append(md_file)

        return md_files

    def _check_required_files(self) -> List[str]:
        """Check that all required files exist."""
        missing = []
        project_root = self.target_path.parent

        for required in self.REQUIRED_FILES:
            if not (project_root / required).exists():
                missing.append(required)

        return missing

    def _check_recommended_files(self) -> List[str]:
        """Check for recommended files (warning if missing)."""
        missing = []
        project_root = self.target_path.parent

        for recommended in self.RECOMMENDED_FILES:
            if not (project_root / recommended).exists():
                missing.append(recommended)

        return missing

    def _find_temporary_files(self, files: List[Path]) -> List[str]:
        """Find temporary/plan files that should be cleaned up."""
        temp_files = []
        project_root = self.target_path.parent

        for filepath in files:
            filename = filepath.name.upper()

            # Check if it's a temporary file pattern
            for pattern in self.TEMPORARY_PATTERNS:
                if pattern.upper() in filename:
                    # Get relative path for cleaner output
                    try:
                        rel_path = filepath.relative_to(project_root)
                    except ValueError:
                        rel_path = filepath
                    temp_files.append(str(rel_path))
                    break

        return temp_files

    def _find_unexpected_root_files(self, files: List[Path]) -> List[str]:
        """Find markdown files at root that aren't in the allowed list."""
        unexpected = []
        project_root = self.target_path.parent

        for filepath in files:
            # Only check files directly in project root
            if filepath.parent == project_root:
                if filepath.name not in self.ALLOWED_ROOT_FILES:
                    # Skip if it's a temporary file (already reported)
                    is_temp = any(p.upper() in filepath.name.upper()
                                  for p in self.TEMPORARY_PATTERNS)
                    if not is_temp:
                        unexpected.append(filepath.name)

        return unexpected

    def _check_readme_locations(self, files: List[Path]) -> List[str]:
        """Check that README.md files are in appropriate locations."""
        misplaced = []
        project_root = self.target_path.parent

        for filepath in files:
            if filepath.name == "README.md":
                # Root README is always allowed
                if filepath.parent == project_root:
                    continue

                # Check if directory is in allowed list
                try:
                    rel_dir = filepath.parent.relative_to(project_root)
                    if str(rel_dir) not in self.ALLOWED_README_DIRS:
                        misplaced.append(str(rel_dir / "README.md"))
                except ValueError:
                    pass

        return misplaced


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("target", help="Path to validate")
    args = parser.parse_args()

    hook = DocumentationHook(Path(args.target))
    result = hook.run()

    print(f"Status: {result.status.value}")
    print(f"Message: {result.message}")
    for detail in result.details:
        print(f"  - {detail}")
