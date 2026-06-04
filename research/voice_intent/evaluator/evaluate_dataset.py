import json
from pathlib import Path
from collections import Counter


DATASET_PATH = Path(__file__).resolve().parents[1] / "dataset" / "fluxa_voice_intent_dataset_sunda_5000.jsonl"


REQUIRED_TOP_LEVEL_FIELDS = {
    "id",
    "split",
    "group",
    "case_type",
    "language_style",
    "raw_text",
    "normalized_text",
    "expected",
    "difficulty",
}

REQUIRED_EXPECTED_FIELDS = {
    "amount",
    "type",
    "category",
    "wallet",
    "note",
    "currency",
}

VALID_SPLITS = {"train", "validation", "test"}
VALID_TYPES = {"income", "expense", "transfer"}
VALID_CURRENCIES = {"IDR"}
VALID_DIFFICULTIES = {"easy", "medium", "hard"}

VALID_CATEGORIES = {
    "Makan & Minum",
    "Transportasi",
    "Belanja",
    "Tagihan & Utilitas",
    "Hiburan",
    "Kesehatan",
    "Gaji",
    "Freelance",
    "Transfer",
}


def load_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        raise FileNotFoundError(f"Dataset not found: {path}")

    rows = []

    with path.open("r", encoding="utf-8") as file:
        for line_number, line in enumerate(file, start=1):
            line = line.strip()

            if not line:
                continue

            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError as error:
                raise ValueError(f"Invalid JSON at line {line_number}: {error}") from error

    return rows


def validate_row(row: dict, index: int) -> list[str]:
    errors = []

    missing_top_fields = REQUIRED_TOP_LEVEL_FIELDS - set(row.keys())
    if missing_top_fields:
        errors.append(f"Row {index}: missing top-level fields: {sorted(missing_top_fields)}")
        return errors

    expected = row.get("expected")
    if not isinstance(expected, dict):
        errors.append(f"Row {index}: expected must be an object")
        return errors

    missing_expected_fields = REQUIRED_EXPECTED_FIELDS - set(expected.keys())
    if missing_expected_fields:
        errors.append(f"Row {index}: missing expected fields: {sorted(missing_expected_fields)}")

    if row["split"] not in VALID_SPLITS:
        errors.append(f"Row {index}: invalid split: {row['split']}")

    if row["difficulty"] not in VALID_DIFFICULTIES:
        errors.append(f"Row {index}: invalid difficulty: {row['difficulty']}")

    if row["language_style"] != "su":
        errors.append(f"Row {index}: language_style must be 'su', got: {row['language_style']}")

    if not isinstance(row["raw_text"], str) or not row["raw_text"].strip():
        errors.append(f"Row {index}: raw_text must be non-empty string")

    if not isinstance(row["normalized_text"], str) or not row["normalized_text"].strip():
        errors.append(f"Row {index}: normalized_text must be non-empty string")

    amount = expected.get("amount")
    if not isinstance(amount, int | float) or amount <= 0:
        errors.append(f"Row {index}: expected.amount must be positive number")

    if expected.get("type") not in VALID_TYPES:
        errors.append(f"Row {index}: invalid expected.type: {expected.get('type')}")

    if expected.get("category") not in VALID_CATEGORIES:
        errors.append(f"Row {index}: invalid expected.category: {expected.get('category')}")

    if expected.get("currency") not in VALID_CURRENCIES:
        errors.append(f"Row {index}: invalid expected.currency: {expected.get('currency')}")

    return errors


def print_distribution(title: str, counter: Counter) -> None:
    print(f"\n## {title}")
    for key, value in counter.most_common():
        print(f"- {key}: {value}")


def main() -> None:
    rows = load_jsonl(DATASET_PATH)

    print("Fluxa Voice Intent Dataset Validator")
    print("=" * 44)
    print(f"Dataset path: {DATASET_PATH}")
    print(f"Total rows: {len(rows)}")

    all_errors = []
    ids = []
    raw_texts = []

    split_counter = Counter()
    group_counter = Counter()
    type_counter = Counter()
    category_counter = Counter()
    difficulty_counter = Counter()
    wallet_counter = Counter()

    for index, row in enumerate(rows, start=1):
        all_errors.extend(validate_row(row, index))

        ids.append(row.get("id"))
        raw_texts.append(row.get("raw_text"))

        expected = row.get("expected", {})

        split_counter[row.get("split")] += 1
        group_counter[row.get("group")] += 1
        type_counter[expected.get("type")] += 1
        category_counter[expected.get("category")] += 1
        difficulty_counter[row.get("difficulty")] += 1
        wallet_counter[expected.get("wallet") or "null"] += 1

    duplicate_ids = len(ids) - len(set(ids))
    duplicate_raw_texts = len(raw_texts) - len(set(raw_texts))

    if duplicate_ids:
        all_errors.append(f"Duplicate IDs found: {duplicate_ids}")

    if duplicate_raw_texts:
        all_errors.append(f"Duplicate raw_text found: {duplicate_raw_texts}")

    print_distribution("Split Distribution", split_counter)
    print_distribution("Group Distribution", group_counter)
    print_distribution("Type Distribution", type_counter)
    print_distribution("Category Distribution", category_counter)
    print_distribution("Difficulty Distribution", difficulty_counter)
    print_distribution("Wallet Distribution", wallet_counter)

    print("\n## Validation Result")
    if all_errors:
        print(f"FAILED: {len(all_errors)} issue(s) found")
        for error in all_errors[:50]:
            print(f"- {error}")

        if len(all_errors) > 50:
            print(f"...and {len(all_errors) - 50} more errors")

        raise SystemExit(1)

    print("PASSED: dataset is valid")


if __name__ == "__main__":
    main()