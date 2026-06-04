import argparse
import csv
import json
import os
import time
from pathlib import Path
from typing import Any

import requests
from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parents[1]
PROJECT_ROOT = Path(__file__).resolve().parents[3]

DATASET_PATH = BASE_DIR / "dataset" / "fluxa_voice_intent_dataset_sunda_5000.jsonl"
RESULTS_DIR = BASE_DIR / "evaluator" / "results"
RESULTS_PATH = RESULTS_DIR / "api_parser_results.csv"

OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses"

VALID_CATEGORIES = [
    "Makan & Minum",
    "Transportasi",
    "Belanja",
    "Tagihan & Utilitas",
    "Hiburan",
    "Kesehatan",
    "Gaji",
    "Freelance",
    "Transfer",
]

VALID_WALLETS = [
    "Cash",
    "BCA",
    "GoPay",
    "Dana",
    "OVO",
    "BRI",
    "Mandiri",
    "ShopeePay",
]


VOICE_INTENT_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "properties": {
        "amount": {
            "type": ["number", "null"],
            "description": "Nominal transaksi dalam IDR. Contoh: 'lima rebu' => 5000."
        },
        "type": {
            "type": ["string", "null"],
            "enum": ["income", "expense", "transfer", None],
            "description": "Jenis transaksi."
        },
        "category": {
            "type": ["string", "null"],
            "enum": VALID_CATEGORIES + [None],
            "description": "Kategori harus dipilih dari daftar kategori valid."
        },
        "wallet": {
            "type": ["string", "null"],
            "enum": VALID_WALLETS + [None],
            "description": "Dompet jika disebut dalam teks, selain itu null."
        },
        "note": {
            "type": ["string", "null"],
            "description": "Catatan singkat transaksi dalam bahasa Sunda/Indonesia sesuai konteks."
        },
        "currency": {
            "type": "string",
            "enum": ["IDR"],
            "description": "Selalu IDR untuk dataset ini."
        },
        "confidence": {
            "type": "number",
            "description": "Confidence 0.0 sampai 1.0."
        },
    },
    "required": [
        "amount",
        "type",
        "category",
        "wallet",
        "note",
        "currency",
        "confidence",
    ],
}


def load_dataset(path: Path) -> list[dict]:
    rows = []

    with path.open("r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if line:
                rows.append(json.loads(line))

    return rows


def build_prompt(row: dict) -> str:
    return f"""
Parse teks transaksi bahasa Sunda berikut menjadi JSON transaksi Fluxa.

Teks mentah:
"{row["raw_text"]}"

Teks hasil normalisasi lokal:
"{row["normalized_text"]}"

Kategori valid:
{", ".join(VALID_CATEGORIES)}

Dompet valid:
{", ".join(VALID_WALLETS)}

Aturan:
- Gunakan amount dari teks jika terdeteksi.
- Jika teks menunjukkan uang keluar, type = "expense".
- Jika teks menunjukkan uang masuk, type = "income".
- Jika teks menunjukkan perpindahan saldo antar dompet, type = "transfer".
- Category wajib salah satu kategori valid.
- Wallet hanya diisi jika teks menyebut dompet valid.
- Currency selalu "IDR".
- Note harus singkat, misalnya "kopi", "parkir motor", "gajih", "kuota internét".
""".strip()


def extract_output_text(response_json: dict[str, Any]) -> str:
    """
    Responses API umumnya mengembalikan output text pada output[].content[].
    Fallback ke output_text jika tersedia.
    """
    if isinstance(response_json.get("output_text"), str):
        return response_json["output_text"]

    output = response_json.get("output", [])
    texts = []

    for item in output:
        for content in item.get("content", []):
            if content.get("type") == "output_text":
                texts.append(content.get("text", ""))

    return "\n".join(texts).strip()


def parse_with_openai(row: dict, api_key: str, model: str, timeout_seconds: int = 60) -> dict:
    payload = {
        "model": model,
        "input": [
            {
                "role": "system",
                "content": (
                    "Kamu adalah parser intent transaksi untuk aplikasi Fluxa. "
                    "Input mayoritas bahasa Sunda percakapan. "
                    "Kembalikan hanya JSON sesuai schema."
                ),
            },
            {
                "role": "user",
                "content": build_prompt(row),
            },
        ],
        "text": {
            "format": {
                "type": "json_schema",
                "name": "fluxa_voice_intent",
                "strict": True,
                "schema": VOICE_INTENT_SCHEMA,
            }
        },
        "temperature": 0,
        "max_output_tokens": 300,
    }

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    response = requests.post(
        OPENAI_RESPONSES_URL,
        headers=headers,
        json=payload,
        timeout=timeout_seconds,
    )

    if response.status_code >= 400:
        raise RuntimeError(f"OpenAI API error {response.status_code}: {response.text}")

    response_json = response.json()
    output_text = extract_output_text(response_json)

    if not output_text:
        raise ValueError(f"Empty output_text. Full response: {response_json}")

    try:
        parsed = json.loads(output_text)
    except json.JSONDecodeError as error:
        raise ValueError(f"Invalid JSON output: {output_text}") from error

    return parsed


def note_match(expected_note: str | None, predicted_note: str | None) -> bool:
    if expected_note is None and predicted_note is None:
        return True

    if not expected_note or not predicted_note:
        return False

    expected_lower = expected_note.lower()
    predicted_lower = predicted_note.lower()

    return expected_lower in predicted_lower or predicted_lower in expected_lower


def compare(expected: dict, predicted: dict) -> dict:
    amount_correct = expected.get("amount") == predicted.get("amount")
    type_correct = expected.get("type") == predicted.get("type")
    category_correct = expected.get("category") == predicted.get("category")
    wallet_correct = expected.get("wallet") == predicted.get("wallet")
    currency_correct = expected.get("currency") == predicted.get("currency")
    note_correct = note_match(expected.get("note"), predicted.get("note"))

    exact_match = all([
        amount_correct,
        type_correct,
        category_correct,
        wallet_correct,
        currency_correct,
    ])

    return {
        "amount_correct": amount_correct,
        "type_correct": type_correct,
        "category_correct": category_correct,
        "wallet_correct": wallet_correct,
        "note_correct": note_correct,
        "currency_correct": currency_correct,
        "exact_match": exact_match,
    }


def safe_parse(row: dict, api_key: str, model: str, retries: int = 2, delay_seconds: float = 1.5) -> tuple[dict | None, str | None]:
    for attempt in range(retries + 1):
        try:
            return parse_with_openai(row, api_key, model), None
        except Exception as error:
            if attempt >= retries:
                return None, str(error)

            time.sleep(delay_seconds * (attempt + 1))

    return None, "Unknown parser error"


def save_results(results: list[dict], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    if not results:
        return

    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=list(results[0].keys()))
        writer.writeheader()
        writer.writerows(results)


def print_summary(results: list[dict]) -> None:
    print("\nAPI Parser Evaluation")
    print("=" * 44)
    print(f"Total evaluated: {len(results)}")

    if not results:
        return

    success_results = [item for item in results if item["status"] == "success"]
    failed_results = [item for item in results if item["status"] == "failed"]

    print(f"Success: {len(success_results)}")
    print(f"Failed: {len(failed_results)}")

    if not success_results:
        return

    for field in ["amount", "type", "category", "wallet", "note", "currency"]:
        key = f"{field}_correct"
        correct = sum(1 for item in success_results if item[key])
        accuracy = correct / len(success_results)
        print(f"{field}_accuracy: {accuracy * 100:.2f}%")

    exact_correct = sum(1 for item in success_results if item["exact_match"])
    print(f"exact_match_accuracy: {(exact_correct / len(success_results)) * 100:.2f}%")


def evaluate(rows: list[dict], api_key: str, model: str) -> list[dict]:
    results = []

    for index, row in enumerate(rows, start=1):
        print(f"[{index}/{len(rows)}] Evaluating {row['id']}...")

        expected = row["expected"]
        predicted, error = safe_parse(row, api_key=api_key, model=model)

        if error:
            results.append({
                "id": row["id"],
                "split": row["split"],
                "group": row["group"],
                "difficulty": row["difficulty"],
                "raw_text": row["raw_text"],
                "normalized_text": row["normalized_text"],
                "status": "failed",
                "error": error,

                "expected_json": json.dumps(expected, ensure_ascii=False),
                "predicted_json": "",

                "amount_correct": False,
                "type_correct": False,
                "category_correct": False,
                "wallet_correct": False,
                "note_correct": False,
                "currency_correct": False,
                "exact_match": False,
            })
            continue

        metrics = compare(expected, predicted)

        results.append({
            "id": row["id"],
            "split": row["split"],
            "group": row["group"],
            "difficulty": row["difficulty"],
            "raw_text": row["raw_text"],
            "normalized_text": row["normalized_text"],
            "status": "success",
            "error": "",

            "expected_json": json.dumps(expected, ensure_ascii=False),
            "predicted_json": json.dumps(predicted, ensure_ascii=False),

            **metrics,
        })

    return results


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--split", default="test", choices=["train", "validation", "test"])
    parser.add_argument("--limit", type=int, default=25)
    parser.add_argument("--model", default=None)
    args = parser.parse_args()

    load_dotenv(PROJECT_ROOT / ".env")

    api_key = os.getenv("OPENAI_API_KEY")
    model = args.model or os.getenv("OPENAI_MODEL", "gpt-5-mini")

    if not api_key:
        raise RuntimeError("OPENAI_API_KEY not found. Add it to your project root .env file.")

    rows = load_dataset(DATASET_PATH)
    selected_rows = [row for row in rows if row["split"] == args.split]

    if args.limit > 0:
        selected_rows = selected_rows[:args.limit]

    print("Fluxa Voice Intent API Parser Evaluator")
    print("=" * 44)
    print(f"Dataset: {DATASET_PATH}")
    print(f"Split: {args.split}")
    print(f"Limit: {args.limit}")
    print(f"Model: {model}")

    results = evaluate(selected_rows, api_key=api_key, model=model)

    output_path = RESULTS_PATH.with_name(
        f"api_parser_results_{args.split}_{args.limit}_{model.replace('/', '_')}.csv"
    )

    save_results(results, output_path)
    print_summary(results)

    print(f"\nSaved result: {output_path}")


if __name__ == "__main__":
    main()