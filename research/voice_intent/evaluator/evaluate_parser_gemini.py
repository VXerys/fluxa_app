"""
Fluxa Voice Intent Gemini Evaluator

Purpose:
- Evaluate Gemini API output against Fluxa Sundanese voice intent golden dataset.
- Produces field-level accuracy: amount/type/category/wallet/note/currency/exact_match.
- Exports row-level results to CSV for analysis.

Expected project structure:
fluxa_app/
└── research/
    └── voice_intent/
        ├── dataset/
        │   └── fluxa_voice_intent_dataset_sunda_5000.jsonl
        └── evaluator/
            ├── evaluate_parser_gemini.py
            └── results/

Setup:
1. pip install -r research/voice_intent/evaluator/requirements_voice_intent_evaluator.txt
2. Copy .env.gemini.example to project root as .env
3. Fill GEMINI_API_KEY
4. Run:
   python research/voice_intent/evaluator/evaluate_parser_gemini.py --split test --limit 10
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import requests
from dotenv import load_dotenv


# ─────────────────────────────────────────────────────────────────────────────
# Paths
# ─────────────────────────────────────────────────────────────────────────────

VOICE_INTENT_DIR = Path(__file__).resolve().parents[1]
PROJECT_ROOT = Path(__file__).resolve().parents[3]

DATASET_PATH = VOICE_INTENT_DIR / "dataset" / "fluxa_voice_intent_dataset_sunda_5000.jsonl"
RESULTS_DIR = VOICE_INTENT_DIR / "evaluator" / "results"


# ─────────────────────────────────────────────────────────────────────────────
# Fluxa contracts
# ─────────────────────────────────────────────────────────────────────────────

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

VALID_TYPES = ["income", "expense", "transfer"]


# Gemini response schema.
# Note:
# Gemini structured output supports schema-constrained JSON responses.
# This schema is intentionally simple to improve compatibility across models.
VOICE_INTENT_SCHEMA: dict[str, Any] = {
    "type": "object",
    "properties": {
        "amount": {
            "type": "number",
            "nullable": True,
            "description": "Nominal transaksi dalam IDR. Contoh: 'lima rebu' => 5000.",
        },
        "type": {
            "type": "string",
            "nullable": True,
            "enum": ["income", "expense", "transfer"],
            "description": "Jenis transaksi.",
        },
        "category": {
            "type": "string",
            "nullable": True,
            "enum": VALID_CATEGORIES,
            "description": "Kategori transaksi. Wajib salah satu kategori valid Fluxa.",
        },
        "wallet": {
            "type": "string",
            "nullable": True,
            "enum": VALID_WALLETS,
            "description": "Dompet jika disebut dalam teks. Jika tidak disebut, null.",
        },
        "note": {
            "type": "string",
            "nullable": True,
            "description": "Catatan singkat. Contoh: kopi, parkir motor, gajih.",
        },
        "currency": {
            "type": "string",
            "enum": ["IDR"],
            "description": "Selalu IDR.",
        },
        "confidence": {
            "type": "number",
            "description": "Confidence 0.0 sampai 1.0.",
        },
    },
    "required": ["amount", "type", "category", "wallet", "note", "currency", "confidence"],
}


# ─────────────────────────────────────────────────────────────────────────────
# Config
# ─────────────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class GeminiConfig:
    api_key: str
    model: str
    api_version: str
    timeout_seconds: int
    max_retries: int
    retry_delay_seconds: float
    use_structured_output: bool

    @property
    def endpoint(self) -> str:
        return (
            f"https://generativelanguage.googleapis.com/{self.api_version}/"
            f"models/{self.model}:generateContent"
        )


def load_config(args: argparse.Namespace) -> GeminiConfig:
    # Search .env from project root first, then current process env.
    load_dotenv(PROJECT_ROOT / ".env")
    load_dotenv(PROJECT_ROOT / ".env.local")

    api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
    if not api_key:
        raise RuntimeError(
            "GEMINI_API_KEY not found. Copy .env.gemini.example to .env "
            "in project root, then fill GEMINI_API_KEY."
        )

    model = args.model or os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
    api_version = os.getenv("GEMINI_API_VERSION", "v1beta")

    return GeminiConfig(
        api_key=api_key,
        model=model,
        api_version=api_version,
        timeout_seconds=args.timeout,
        max_retries=args.retries,
        retry_delay_seconds=args.retry_delay,
        use_structured_output=not args.no_structured_output,
    )


# ─────────────────────────────────────────────────────────────────────────────
# Dataset
# ─────────────────────────────────────────────────────────────────────────────

def load_dataset(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        raise FileNotFoundError(f"Dataset not found: {path}")

    rows: list[dict[str, Any]] = []

    with path.open("r", encoding="utf-8") as file:
        for line_number, line in enumerate(file, start=1):
            line = line.strip()
            if not line:
                continue

            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError as error:
                raise ValueError(f"Invalid JSONL at line {line_number}: {error}") from error

    return rows


def select_rows(rows: list[dict[str, Any]], split: str, limit: int, offset: int) -> list[dict[str, Any]]:
    selected = [row for row in rows if row.get("split") == split]

    if offset > 0:
        selected = selected[offset:]

    if limit > 0:
        selected = selected[:limit]

    return selected


# ─────────────────────────────────────────────────────────────────────────────
# Prompting
# ─────────────────────────────────────────────────────────────────────────────

def build_prompt(row: dict[str, Any]) -> str:
    return f"""
Kamu adalah parser intent transaksi untuk aplikasi Fluxa.

Input adalah bahasa Sunda percakapan. Tugas kamu adalah mengekstrak data transaksi,
bukan menerjemahkan teks secara bebas.

Teks mentah:
"{row["raw_text"]}"

Teks hasil normalisasi lokal:
"{row["normalized_text"]}"

Kategori valid Fluxa:
{", ".join(VALID_CATEGORIES)}

Dompet valid:
{", ".join(VALID_WALLETS)}

Aturan parsing:
1. Gunakan teks normalisasi sebagai sumber utama untuk amount.
2. Jika uang keluar / dipakai / mayar / meuli / mésér / jajan, type = "expense".
3. Jika uang masuk / asup / nampi / narima / meunang / dibayar, type = "income".
4. Jika perpindahan saldo antar dompet / transfer / top up, type = "transfer".
5. Category wajib salah satu dari kategori valid.
6. Wallet hanya diisi jika teks menyebut salah satu dompet valid.
7. Jika dompet tidak disebut, wallet = null.
8. Currency selalu "IDR".
9. Note harus singkat dan spesifik, contoh: "kopi", "parkir motor", "kuota internét", "gajih".
10. Kembalikan hanya JSON valid sesuai schema.
""".strip()


# ─────────────────────────────────────────────────────────────────────────────
# Gemini API
# ─────────────────────────────────────────────────────────────────────────────

def build_payload(row: dict[str, Any], config: GeminiConfig) -> dict[str, Any]:
    generation_config: dict[str, Any] = {
        "temperature": 0,
        "topP": 0.1,
        "maxOutputTokens": 512,
        "responseMimeType": "application/json",
    }

    if config.use_structured_output:
        generation_config["responseSchema"] = VOICE_INTENT_SCHEMA

    return {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {"text": build_prompt(row)}
                ],
            }
        ],
        "generationConfig": generation_config,
    }


def extract_text_from_gemini_response(response_json: dict[str, Any]) -> str:
    candidates = response_json.get("candidates") or []
    if not candidates:
        raise ValueError(f"No candidates returned: {json.dumps(response_json, ensure_ascii=False)}")

    first = candidates[0]
    content = first.get("content") or {}
    parts = content.get("parts") or []

    texts: list[str] = []
    for part in parts:
        text = part.get("text")
        if isinstance(text, str):
            texts.append(text)

    output_text = "\n".join(texts).strip()

    if not output_text:
        raise ValueError(f"Empty text response: {json.dumps(response_json, ensure_ascii=False)}")

    return output_text


def sanitize_json_text(text: str) -> str:
    text = text.strip()

    # Safety fallback if model returns fenced markdown despite JSON instruction.
    if text.startswith("```"):
        text = text.removeprefix("```json").removeprefix("```").strip()
        text = text.removesuffix("```").strip()

    return text


def normalize_predicted_json(data: dict[str, Any]) -> dict[str, Any]:
    """
    Normalize model output to Fluxa contract.
    Keeps evaluator stable even if model returns int as float or empty strings.
    """
    amount = data.get("amount")
    if isinstance(amount, str):
        digits = "".join(ch for ch in amount if ch.isdigit())
        amount = int(digits) if digits else None

    if isinstance(amount, float) and amount.is_integer():
        amount = int(amount)

    predicted_type = data.get("type")
    if predicted_type not in VALID_TYPES:
        predicted_type = None

    category = data.get("category")
    if category not in VALID_CATEGORIES:
        category = None

    wallet = data.get("wallet")
    if wallet == "":
        wallet = None
    if wallet not in VALID_WALLETS:
        wallet = None

    note = data.get("note")
    if note == "":
        note = None

    currency = data.get("currency") or "IDR"
    if currency != "IDR":
        currency = "IDR"

    confidence = data.get("confidence")
    if not isinstance(confidence, int | float):
        confidence = 0.0
    confidence = max(0.0, min(float(confidence), 1.0))

    return {
        "amount": amount,
        "type": predicted_type,
        "category": category,
        "wallet": wallet,
        "note": note,
        "currency": currency,
        "confidence": confidence,
    }


def parse_with_gemini(row: dict[str, Any], config: GeminiConfig) -> dict[str, Any]:
    response = requests.post(
        config.endpoint,
        headers={
            "Content-Type": "application/json",
            "x-goog-api-key": config.api_key,
        },
        json=build_payload(row, config),
        timeout=config.timeout_seconds,
    )

    if response.status_code >= 400:
        raise RuntimeError(f"Gemini API error {response.status_code}: {response.text}")

    response_json = response.json()
    output_text = sanitize_json_text(extract_text_from_gemini_response(response_json))

    try:
        parsed = json.loads(output_text)
    except json.JSONDecodeError as error:
        raise ValueError(f"Gemini returned invalid JSON: {output_text}") from error

    if not isinstance(parsed, dict):
        raise ValueError(f"Gemini JSON output must be object, got: {type(parsed)}")

    return normalize_predicted_json(parsed)


def safe_parse_with_gemini(row: dict[str, Any], config: GeminiConfig) -> tuple[dict[str, Any] | None, str | None]:
    for attempt in range(config.max_retries + 1):
        try:
            return parse_with_gemini(row, config), None
        except Exception as error:
            if attempt >= config.max_retries:
                return None, str(error)

            sleep_for = config.retry_delay_seconds * (attempt + 1)
            time.sleep(sleep_for)

    return None, "Unknown parser error"


# ─────────────────────────────────────────────────────────────────────────────
# Metrics
# ─────────────────────────────────────────────────────────────────────────────

def note_match(expected_note: str | None, predicted_note: str | None) -> bool:
    """
    Note is semantic-ish and should not be evaluated too strictly.
    Example:
    expected = "kuota internét"
    predicted = "kuota"
    should be counted as acceptable.
    """
    if expected_note is None and predicted_note is None:
        return True

    if not expected_note or not predicted_note:
        return False

    expected_lower = expected_note.lower().strip()
    predicted_lower = predicted_note.lower().strip()

    return expected_lower in predicted_lower or predicted_lower in expected_lower


def compare_expected_predicted(expected: dict[str, Any], predicted: dict[str, Any]) -> dict[str, bool]:
    amount_correct = expected.get("amount") == predicted.get("amount")
    type_correct = expected.get("type") == predicted.get("type")
    category_correct = expected.get("category") == predicted.get("category")
    wallet_correct = expected.get("wallet") == predicted.get("wallet")
    note_correct = note_match(expected.get("note"), predicted.get("note"))
    currency_correct = expected.get("currency") == predicted.get("currency")

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


def calculate_accuracy(results: list[dict[str, Any]], key: str) -> float:
    success_results = [row for row in results if row["status"] == "success"]
    if not success_results:
        return 0.0

    correct = sum(1 for row in success_results if row.get(key) is True)
    return correct / len(success_results)


# ─────────────────────────────────────────────────────────────────────────────
# Evaluation
# ─────────────────────────────────────────────────────────────────────────────

def evaluate_rows(rows: list[dict[str, Any]], config: GeminiConfig, sleep_between_requests: float) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []

    for index, row in enumerate(rows, start=1):
        print(f"[{index}/{len(rows)}] Evaluating {row['id']}...")

        expected = row["expected"]
        predicted, error = safe_parse_with_gemini(row, config)

        if error or predicted is None:
            results.append({
                "id": row["id"],
                "split": row["split"],
                "group": row["group"],
                "case_type": row["case_type"],
                "difficulty": row["difficulty"],
                "raw_text": row["raw_text"],
                "normalized_text": row["normalized_text"],
                "status": "failed",
                "error": error or "Unknown error",
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
        else:
            metrics = compare_expected_predicted(expected, predicted)
            results.append({
                "id": row["id"],
                "split": row["split"],
                "group": row["group"],
                "case_type": row["case_type"],
                "difficulty": row["difficulty"],
                "raw_text": row["raw_text"],
                "normalized_text": row["normalized_text"],
                "status": "success",
                "error": "",
                "expected_json": json.dumps(expected, ensure_ascii=False),
                "predicted_json": json.dumps(predicted, ensure_ascii=False),
                **metrics,
            })

        if sleep_between_requests > 0 and index < len(rows):
            time.sleep(sleep_between_requests)

    return results


def save_results(results: list[dict[str, Any]], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    if not results:
        return

    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=list(results[0].keys()))
        writer.writeheader()
        writer.writerows(results)


def print_summary(results: list[dict[str, Any]]) -> None:
    print("\nGemini Parser Evaluation Summary")
    print("=" * 44)
    print(f"Total evaluated: {len(results)}")

    success = [row for row in results if row["status"] == "success"]
    failed = [row for row in results if row["status"] == "failed"]

    print(f"Success: {len(success)}")
    print(f"Failed: {len(failed)}")

    if not success:
        print("No successful rows to score.")
        return

    metric_keys = [
        ("amount_accuracy", "amount_correct"),
        ("type_accuracy", "type_correct"),
        ("category_accuracy", "category_correct"),
        ("wallet_accuracy", "wallet_correct"),
        ("note_accuracy_soft", "note_correct"),
        ("currency_accuracy", "currency_correct"),
        ("exact_match_accuracy", "exact_match"),
    ]

    for label, key in metric_keys:
        print(f"{label}: {calculate_accuracy(results, key) * 100:.2f}%")

    print("\nBy group exact_match:")
    groups = sorted({row["group"] for row in success})
    for group in groups:
        group_rows = [row for row in success if row["group"] == group]
        exact = sum(1 for row in group_rows if row["exact_match"]) / len(group_rows)
        print(f"- {group}: {exact * 100:.2f}% ({len(group_rows)} rows)")


# ─────────────────────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────────────────────

def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Evaluate Gemini parser against Fluxa Sundanese voice intent dataset."
    )

    parser.add_argument("--split", default="test", choices=["train", "validation", "test"])
    parser.add_argument("--limit", type=int, default=10, help="Number of rows to evaluate. Use 0 for all selected rows.")
    parser.add_argument("--offset", type=int, default=0, help="Skip N rows from selected split.")
    parser.add_argument("--model", default=None, help="Override GEMINI_MODEL from .env.")
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--retries", type=int, default=2)
    parser.add_argument("--retry-delay", type=float, default=2.0)
    parser.add_argument("--sleep", type=float, default=0.25, help="Delay between requests to reduce rate-limit risk.")
    parser.add_argument(
        "--no-structured-output",
        action="store_true",
        help="Disable responseSchema and use JSON MIME only. Useful if selected model rejects schema.",
    )

    return parser


def main() -> None:
    args = build_arg_parser().parse_args()
    config = load_config(args)

    rows = load_dataset(DATASET_PATH)
    selected_rows = select_rows(rows, split=args.split, limit=args.limit, offset=args.offset)

    if not selected_rows:
        raise RuntimeError("No rows selected. Check --split, --limit, and --offset.")

    print("Fluxa Voice Intent Gemini Evaluator")
    print("=" * 44)
    print(f"Dataset: {DATASET_PATH}")
    print(f"Split: {args.split}")
    print(f"Limit: {args.limit}")
    print(f"Offset: {args.offset}")
    print(f"Model: {config.model}")
    print(f"Structured output: {config.use_structured_output}")
    print(f"Selected rows: {len(selected_rows)}")

    results = evaluate_rows(
        rows=selected_rows,
        config=config,
        sleep_between_requests=args.sleep,
    )

    safe_model_name = config.model.replace("/", "_").replace(":", "_")
    output_path = RESULTS_DIR / f"gemini_parser_results_{args.split}_limit{args.limit}_offset{args.offset}_{safe_model_name}.csv"

    save_results(results, output_path)
    print_summary(results)

    print(f"\nSaved result: {output_path}")


if __name__ == "__main__":
    main()
