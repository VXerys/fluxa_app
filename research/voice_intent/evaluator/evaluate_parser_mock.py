import csv
import json
import re
from pathlib import Path
from collections import Counter


BASE_DIR = Path(__file__).resolve().parents[1]
DATASET_PATH = BASE_DIR / "dataset" / "fluxa_voice_intent_dataset_sunda_5000.jsonl"
RESULTS_DIR = BASE_DIR / "evaluator" / "results"
RESULTS_PATH = RESULTS_DIR / "mock_parser_results.csv"

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

VALID_TYPES = {"income", "expense", "transfer"}

CATEGORY_KEYWORDS = {
    "Makan & Minum": [
        "kopi", "dahar", "sangu", "goreng", "hayam", "seblak", "baso",
        "téh", "roti", "cilok", "makan"
    ],
    "Transportasi": [
        "parkir", "motor", "bensin", "ojék", "ojek", "ojol", "angkot", "tol"
    ],
    "Belanja": [
        "sabun", "sampo", "alat tulis", "baju", "sapatu", "balanja",
        "skincare", "belanja"
    ],
    "Tagihan & Utilitas": [
        "pulsa", "kuota", "internét", "internet", "listrik", "cai",
        "wifi", "langganan"
    ],
    "Hiburan": [
        "bioskop", "game", "karaoke", "netflix", "konser", "tiket"
    ],
    "Kesehatan": [
        "ubar", "obat", "vitamin", "dokter", "masker", "apoték", "apotek"
    ],
    "Gaji": [
        "gajih", "gaji", "duit bulanan", "bonus damel", "bonus kerja"
    ],
    "Freelance": [
        "freelance", "proyék", "project", "desain", "logo", "website",
        "bug aplikasi", "ngalereskeun", "ngadamel"
    ],
    "Transfer": [
        "transfer", "mindahkeun", "kirim", "top up"
    ],
}

INCOME_KEYWORDS = [
    "asup", "nampi", "narima", "meunang", "dibayar", "bayaran",
    "saldo nambahan", "duit asup", "gajih", "bonus"
]

EXPENSE_KEYWORDS = [
    "meuli", "mésér", "meser", "mli", "mayar", "myr", "jajan",
    "ngeusian", "ngisi", "kaluar", "kapaké", "habis", "balanja"
]

TRANSFER_KEYWORDS = [
    "transfer", "mindahkeun", "kirim", "top up"
]

WALLETS = ["Cash", "BCA", "GoPay", "Dana", "OVO", "BRI", "Mandiri", "ShopeePay"]


def load_dataset(path: Path) -> list[dict]:
    rows = []

    with path.open("r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if line:
                rows.append(json.loads(line))

    return rows


def extract_amount_from_normalized_text(text: str) -> int | None:
    numbers = re.findall(r"\d+", text)
    if not numbers:
        return None

    # Ambil angka terbesar agar "poé ieu" / angka kecil lain tidak mengganggu.
    return max(int(number) for number in numbers)


def detect_wallet(text: str) -> str | None:
    text_lower = text.lower()

    for wallet in WALLETS:
        if wallet.lower() in text_lower:
            return wallet

    return None


def detect_type(text: str) -> str | None:
    text_lower = text.lower()

    if any(keyword in text_lower for keyword in TRANSFER_KEYWORDS):
        return "transfer"

    if any(keyword in text_lower for keyword in INCOME_KEYWORDS):
        return "income"

    if any(keyword in text_lower for keyword in EXPENSE_KEYWORDS):
        return "expense"

    return None


def detect_category(text: str, predicted_type: str | None) -> str | None:
    text_lower = text.lower()

    if predicted_type == "transfer":
        return "Transfer"

    best_category = None
    best_score = 0

    for category, keywords in CATEGORY_KEYWORDS.items():
        if category == "Transfer" and predicted_type != "transfer":
            continue

        score = sum(1 for keyword in keywords if keyword.lower() in text_lower)

        if score > best_score:
            best_score = score
            best_category = category

    return best_category


def extract_note(text: str, category: str | None) -> str | None:
    if not category:
        return None

    text_lower = text.lower()

    for keyword in CATEGORY_KEYWORDS.get(category, []):
        if keyword.lower() in text_lower:
            return keyword

    return None


def mock_parse(row: dict) -> dict:
    """
    Mock parser rule-based sederhana.
    Tujuannya bukan akurasi sempurna, tapi memastikan evaluator pipeline berjalan.
    """
    text = row["normalized_text"]

    predicted_type = detect_type(text)
    predicted_category = detect_category(text, predicted_type)
    predicted_amount = extract_amount_from_normalized_text(text)
    predicted_wallet = detect_wallet(text)
    predicted_note = extract_note(text, predicted_category)

    return {
        "amount": predicted_amount,
        "type": predicted_type,
        "category": predicted_category,
        "wallet": predicted_wallet,
        "note": predicted_note,
        "currency": "IDR",
        "confidence": 0.70,
    }


def compare_field(expected: dict, predicted: dict, field: str) -> bool:
    return expected.get(field) == predicted.get(field)


def note_match(expected_note: str | None, predicted_note: str | None) -> bool:
    """
    Note tidak dibuat strict 100%.
    Contoh expected: "kuota internét", predicted: "kuota" tetap dianggap match.
    """
    if expected_note is None and predicted_note is None:
        return True

    if not expected_note or not predicted_note:
        return False

    expected_lower = expected_note.lower()
    predicted_lower = predicted_note.lower()

    return expected_lower in predicted_lower or predicted_lower in expected_lower


def evaluate(rows: list[dict]) -> list[dict]:
    results = []

    for row in rows:
        expected = row["expected"]
        predicted = mock_parse(row)

        amount_correct = compare_field(expected, predicted, "amount")
        type_correct = compare_field(expected, predicted, "type")
        category_correct = compare_field(expected, predicted, "category")
        wallet_correct = compare_field(expected, predicted, "wallet")
        currency_correct = compare_field(expected, predicted, "currency")
        note_correct = note_match(expected.get("note"), predicted.get("note"))

        exact_match = all([
            amount_correct,
            type_correct,
            category_correct,
            wallet_correct,
            currency_correct,
        ])

        results.append({
            "id": row["id"],
            "split": row["split"],
            "group": row["group"],
            "difficulty": row["difficulty"],
            "raw_text": row["raw_text"],
            "normalized_text": row["normalized_text"],

            "expected_amount": expected.get("amount"),
            "predicted_amount": predicted.get("amount"),
            "amount_correct": amount_correct,

            "expected_type": expected.get("type"),
            "predicted_type": predicted.get("type"),
            "type_correct": type_correct,

            "expected_category": expected.get("category"),
            "predicted_category": predicted.get("category"),
            "category_correct": category_correct,

            "expected_wallet": expected.get("wallet"),
            "predicted_wallet": predicted.get("wallet"),
            "wallet_correct": wallet_correct,

            "expected_note": expected.get("note"),
            "predicted_note": predicted.get("note"),
            "note_correct": note_correct,

            "expected_currency": expected.get("currency"),
            "predicted_currency": predicted.get("currency"),
            "currency_correct": currency_correct,

            "exact_match": exact_match,
            "predicted_json": json.dumps(predicted, ensure_ascii=False),
        })

    return results


def accuracy(results: list[dict], field: str) -> float:
    if not results:
        return 0.0

    key = f"{field}_correct"
    correct_count = sum(1 for item in results if item[key])
    return correct_count / len(results)


def print_summary(results: list[dict]) -> None:
    print("\nMock Parser Evaluation")
    print("=" * 44)
    print(f"Total evaluated: {len(results)}")

    for field in ["amount", "type", "category", "wallet", "note", "currency"]:
        print(f"{field}_accuracy: {accuracy(results, field) * 100:.2f}%")

    exact_match_count = sum(1 for item in results if item["exact_match"])
    exact_match_accuracy = exact_match_count / len(results) if results else 0.0
    print(f"exact_match_accuracy: {exact_match_accuracy * 100:.2f}%")

    group_counter = Counter(item["group"] for item in results)
    print("\nBy group:")
    for group, count in group_counter.most_common():
        group_results = [item for item in results if item["group"] == group]
        group_exact = sum(1 for item in group_results if item["exact_match"]) / count
        print(f"- {group}: {group_exact * 100:.2f}% exact match ({count} rows)")


def save_results(results: list[dict], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    if not results:
        return

    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=list(results[0].keys()))
        writer.writeheader()
        writer.writerows(results)


def main() -> None:
    rows = load_dataset(DATASET_PATH)

    # Evaluasi split test dulu agar cepat dan adil.
    test_rows = [row for row in rows if row["split"] == "test"]

    results = evaluate(test_rows)

    print_summary(results)
    save_results(results, RESULTS_PATH)

    print(f"\nSaved result: {RESULTS_PATH}")


if __name__ == "__main__":
    main()