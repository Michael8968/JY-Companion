"""Validate corpus data files before import.

Checks JSONL files for structural correctness, required fields, cross-references
between knowledge chunks, graph data, and exercises.

Usage:
    python -m scripts.corpus.validate_corpus data/corpus/math/
"""

import json
import sys
from pathlib import Path

import structlog

logger = structlog.get_logger()


class CorpusValidator:
    """Validate a corpus directory for consistency and completeness."""

    def __init__(self, corpus_dir: Path):
        self.corpus_dir = corpus_dir
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.stats: dict = {}

    def _load_jsonl(self, filename: str) -> list[dict]:
        filepath = self.corpus_dir / filename
        if not filepath.exists():
            self.errors.append(f"Missing file: {filename}")
            return []
        items = []
        with open(filepath, encoding="utf-8") as f:
            for lineno, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue
                try:
                    items.append(json.loads(line))
                except json.JSONDecodeError as e:
                    self.errors.append(f"{filename}:{lineno}: Invalid JSON — {e}")
        return items

    def validate_knowledge_chunks(self) -> list[dict]:
        """Validate knowledge_chunks.jsonl."""
        chunks = self._load_jsonl("knowledge_chunks.jsonl")
        self.stats["knowledge_chunks"] = len(chunks)

        ids = set()
        for i, c in enumerate(chunks):
            prefix = f"knowledge_chunks.jsonl:{i + 1}"
            # Required fields
            for field in ("subject", "chapter", "content"):
                if field not in c:
                    self.errors.append(f"{prefix}: Missing field '{field}'")
            # Content length
            content = c.get("content", "")
            if len(content) < 20:
                self.warnings.append(f"{prefix}: Content too short ({len(content)} chars)")
            if len(content) > 8192:
                self.errors.append(f"{prefix}: Content exceeds Milvus VARCHAR limit (8192)")
            # Duplicate ID
            cid = c.get("id", "")
            if cid in ids:
                self.errors.append(f"{prefix}: Duplicate id '{cid}'")
            ids.add(cid)
            # Difficulty/importance range
            for field in ("difficulty", "importance"):
                val = c.get(field)
                if val is not None and not (1 <= val <= 5):
                    self.warnings.append(f"{prefix}: {field}={val} outside [1,5]")
        return chunks

    def validate_knowledge_graph(self) -> dict[str, list[dict]]:
        """Validate knowledge_graph.jsonl."""
        items = self._load_jsonl("knowledge_graph.jsonl")
        grouped: dict[str, list[dict]] = {"subject": [], "chapter": [], "knowledge_point": []}
        for i, item in enumerate(items):
            prefix = f"knowledge_graph.jsonl:{i + 1}"
            t = item.get("type")
            if t not in grouped:
                self.errors.append(f"{prefix}: Unknown type '{t}'")
                continue
            if "name" not in item:
                self.errors.append(f"{prefix}: Missing 'name'")
            grouped[t].append(item)

        self.stats["graph_subjects"] = len(grouped["subject"])
        self.stats["graph_chapters"] = len(grouped["chapter"])
        self.stats["graph_knowledge_points"] = len(grouped["knowledge_point"])

        # Cross-reference: chapter subjects must reference existing subjects
        subject_names = {s["name"] for s in grouped["subject"]}
        for ch in grouped["chapter"]:
            if ch.get("subject") not in subject_names:
                self.warnings.append(
                    f"Chapter '{ch.get('name')}' references unknown subject '{ch.get('subject')}'"
                )

        # Cross-reference: KP chapters must exist
        chapter_keys = {(ch.get("name"), ch.get("subject")) for ch in grouped["chapter"]}
        kp_names = {kp["name"] for kp in grouped["knowledge_point"]}
        for kp in grouped["knowledge_point"]:
            key = (kp.get("chapter"), kp.get("subject"))
            if key not in chapter_keys:
                self.warnings.append(
                    f"KnowledgePoint '{kp.get('name')}' references unknown chapter '{kp.get('chapter')}'"
                )
            # Prerequisite/related references
            for prereq in kp.get("prerequisites", []):
                if prereq not in kp_names:
                    self.warnings.append(
                        f"KP '{kp.get('name')}' has prerequisite '{prereq}' not in graph"
                    )
            for rel in kp.get("related", []):
                if rel not in kp_names:
                    self.warnings.append(
                        f"KP '{kp.get('name')}' has related '{rel}' not in graph"
                    )

        return grouped

    def validate_exercises(self, kp_names: set[str]) -> list[dict]:
        """Validate exercises.jsonl against known knowledge points."""
        exercises = self._load_jsonl("exercises.jsonl")
        self.stats["exercises"] = len(exercises)

        ids = set()
        for i, ex in enumerate(exercises):
            prefix = f"exercises.jsonl:{i + 1}"
            for field in ("knowledge_point", "content", "answer"):
                if field not in ex:
                    self.errors.append(f"{prefix}: Missing field '{field}'")
            # Duplicate ID
            eid = ex.get("id", "")
            if eid in ids:
                self.errors.append(f"{prefix}: Duplicate id '{eid}'")
            ids.add(eid)
            # Cross-reference KP
            kp = ex.get("knowledge_point", "")
            if kp and kp not in kp_names:
                self.warnings.append(f"{prefix}: knowledge_point '{kp}' not found in graph")
            # Type check
            ex_type = ex.get("type", "")
            if ex_type and ex_type not in ("choice", "fill", "solution", "true_false"):
                self.warnings.append(f"{prefix}: Unknown exercise type '{ex_type}'")
        return exercises

    def validate_all(self) -> bool:
        """Run all validations. Returns True if no errors."""
        self.validate_knowledge_chunks()
        graph = self.validate_knowledge_graph()
        kp_names = {kp["name"] for kp in graph["knowledge_point"]}
        self.validate_exercises(kp_names)

        # Coverage check: do all KPs have at least one exercise?
        exercises = self._load_jsonl("exercises.jsonl")
        covered_kps = {ex.get("knowledge_point") for ex in exercises}
        uncovered = kp_names - covered_kps
        if uncovered:
            self.warnings.append(
                f"{len(uncovered)} knowledge points without exercises: {', '.join(sorted(uncovered))}"
            )

        # Do all KPs have knowledge chunks?
        chunks = self._load_jsonl("knowledge_chunks.jsonl")
        # Build a rough title→exists set
        chunk_titles = {c.get("title", "") for c in chunks}
        for kp_name in kp_names:
            if kp_name not in chunk_titles:
                self.warnings.append(f"KP '{kp_name}' has no matching knowledge chunk (by title)")

        return len(self.errors) == 0

    def print_report(self) -> None:
        """Print validation report to stdout."""
        print("=" * 60)
        print(f"Corpus Validation Report: {self.corpus_dir}")
        print("=" * 60)
        print(f"\nStatistics:")
        for k, v in self.stats.items():
            print(f"  {k}: {v}")

        if self.errors:
            print(f"\nERRORS ({len(self.errors)}):")
            for e in self.errors:
                print(f"  [E] {e}")
        else:
            print("\nNo errors found.")

        if self.warnings:
            print(f"\nWARNINGS ({len(self.warnings)}):")
            for w in self.warnings:
                print(f"  [W] {w}")
        else:
            print("\nNo warnings.")

        print("\n" + ("PASS" if not self.errors else "FAIL"))


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Validate corpus data files")
    parser.add_argument("corpus_dir", type=Path, help="Directory containing JSONL corpus files")
    args = parser.parse_args()

    if not args.corpus_dir.is_dir():
        print(f"Error: Not a directory: {args.corpus_dir}")
        sys.exit(1)

    validator = CorpusValidator(args.corpus_dir)
    is_valid = validator.validate_all()
    validator.print_report()
    sys.exit(0 if is_valid else 1)


if __name__ == "__main__":
    main()
