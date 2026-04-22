#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_DIR="$SCRIPT_DIR/python"
FAILED=0
PASSED=0
SKIPPED=0

examine_session() {
    local session_dir="$1"
    local session_name
    session_name="$(basename "$session_dir")"

    echo ""
    echo "=============================="
    echo "  Testing $session_name"
    echo "=============================="

    local py_files=()
    while IFS= read -r -d '' file; do
        py_files+=("$file")
    done < <(find "$session_dir" -maxdepth 1 -name "*.py" -print0 | sort -z)

    if [ ${#py_files[@]} -eq 0 ]; then
        echo "[⚠️]  No .py files found in $session_name"
        return 0
    fi

    local lab1_file=""
    for file in "${py_files[@]}"; do
        local basename
        basename="$(basename "$file")"
        if [[ "$basename" == lab1_* ]]; then
            lab1_file="$file"
            break
        fi
    done

    if [ -n "$lab1_file" ]; then
        echo "[🔍] Gate check: $(basename "$lab1_file")"
        pylint --disable=C0301 "$lab1_file" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "[🟨] pylint warnings on $(basename "$lab1_file") (non-blocking)"
        fi

        python "$lab1_file"
        if [ $? -ne 0 ]; then
            echo "[🟨] $(basename "$lab1_file") failed — skipping rest of $session_name (not started yet)"
            SKIPPED=$((SKIPPED + 1))
            return 0
        fi
        echo "[🟩] Gate check passed for $session_name"
    fi

    local all_passed=true
    for file in "${py_files[@]}"; do
        if [ "$file" = "$lab1_file" ]; then
            continue
        fi

        local basename
        basename="$(basename "$file")"
        pylint --disable=C0301 "$file" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "[🟨] pylint warnings on $basename (non-blocking)"
        fi

        python "$file"
        if [ $? -ne 0 ]; then
            echo "[🟥] Error running $basename in $session_name"
            all_passed=false
        else
            echo "[🟩] $basename ran successfully"
        fi
    done

    if [ "$all_passed" = true ]; then
        PASSED=$((PASSED + 1))
        echo "[🟩] $session_name completed successfully"
    else
        FAILED=$((FAILED + 1))
        echo "[🟥] $session_name has failures"
    fi
}

echo "=============================================="
echo "     EL2026 Python Lab Test Runner"
echo "=============================================="

if [ ! -d "$PYTHON_DIR" ]; then
    echo "[🟥] Python directory not found: $PYTHON_DIR"
    exit 1
fi

sessions=()
while IFS= read -r -d '' dir; do
    sessions+=("$dir")
done < <(find "$PYTHON_DIR" -maxdepth 1 -type d -name "session*" -print0 | sort -z)

if [ ${#sessions[@]} -eq 0 ]; then
    echo "[⚠️]  No session directories found in $PYTHON_DIR"
    exit 0
fi

echo "[ℹ️]  Found ${#sessions[@]} session(s):"
for s in "${sessions[@]}"; do
    echo "      - $(basename "$s")"
done

for session in "${sessions[@]}"; do
    examine_session "$session"
done

echo ""
echo "=============================================="
echo "  Summary: $PASSED passed | $FAILED failed | $SKIPPED not started"
echo "=============================================="

if [ $FAILED -gt 0 ]; then
    echo "[🟥] Some sessions have failures — please fix and retry"
    exit 1
fi

echo "[🎉] All attempted sessions passed!"
exit 0
