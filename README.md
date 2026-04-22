# EL2026 - Embedded Linux Diploma Python Laboratory Exercises

This repository contains Python laboratory exercises for the Embedded Linux Diploma EL2026 program. Labs are organized by sessions and tested automatically via a flexible CI pipeline that adapts to your progress.

## How the Pipeline Works

The CI pipeline is **session-aware** — it auto-discovers all `session*` directories under `python/` and runs them with a **gate-check** pattern:

- **Gate check**: Each session's `lab1_*.py` is run first as an entry check
- **If gate passes** → all remaining labs in that session are tested (failures here are reported as errors)
- **If gate fails** → the entire session is **skipped** (you haven't started it yet, so it won't break your pipeline)

This means:
- A student on session 2 won't fail CI because sessions 3+ aren't solved
- A student on session 5 can push without worrying about future sessions
- New sessions can be added anytime without modifying any scripts

## Repository Structure

```
python/
├── session1/
│   ├── lab1_list_count.py          # Count occurrences in lists
│   ├── lab2_vowel_or_not.py        # Vowel checking functions
│   ├── lab3_access_env.py          # Environment variable access
│   ├── lab4_area_circle.py         # Circle area calculations
│   └── lab5_accumulator.py         # Accumulator patterns
├── session2/
│   ├── lab1_get_your_location.py   # Geolocation with APIs
│   ├── lab2_lists_problems.py      # Advanced list operations
│   ├── lab3_tuple_problems.py      # Tuple manipulation
│   └── lab4_set_problems.py        # Set operations and theory
└── session3/
    ├── lab1_dictionary_problems.py # Dictionary data structures
    ├── lab2_parse_file.py          # File parsing and processing
    └── template_data.txt           # Sample data for parsing
```

## Getting Started

### Prerequisites
- Python 3.9 or higher
- Git
- pip packages: `pylint`, `requests`

### Setup

```bash
git clone <your-fork-url>
cd EL2026
pip install pylint requests
```

## Running Tests

### Run all sessions
```bash
chmod +x run_python.sh
./run_python.sh
```

### Run individual labs
```bash
python python/session1/lab1_list_count.py
pylint --disable=C0301 python/session1/lab1_list_count.py
```

## CI/CD

The pipeline triggers on any push/PR that modifies files under `python/`. It tests across Python 3.9–3.13.

### Status meanings
- **🟩 Passed** — session fully solved
- **🟨 Skipped** — gate check failed (you haven't started this session yet — this is OK)
- **🟥 Failed** — gate passed but one or more labs in the session have errors

## Best Practices

- Work on feature branches (`git checkout -b session1/lab1-solution`)
- Don't modify test cases or function signatures
- Test frequently with `./run_python.sh` before pushing
- Each session is independent — complete them in order at your own pace
