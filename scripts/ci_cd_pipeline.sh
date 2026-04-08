#!/bin/bash

step() {
  local step_name="$1"
  shift
  local hint="$1"
  shift

  local stdout_file="$(mktemp)"
  local stderr_file="$(mktemp)"

  echo -n "$step_name... "
  local start_time=$(date +%s)
  "$@" > $stdout_file 2> $stderr_file
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  if [ $? -eq 0 ]; then
    echo "✅ (${duration}s)"
  else
    echo "❌ (${duration}s)"
    echo "\"$*\" has failed. $hint"
    echo "STDOUT:"
    cat "$stdout_file"
    echo "STDERR:"
    cat "$stderr_file"
  fi

  rm "$stdout_file"
  rm "$stderr_file"
}

verify_coverage_at_least() {
  local threshold="$1"

  local cov_summary=$(lcov --list coverage/lcov.info)
  local line_cov_perc=$(grep "Total:|" <<< $cov_summary | grep -o "[0-9]*" | head -1)

  if [ "$line_cov_perc" -lt "$threshold" ]; then
    echo "Line coverage ($line_cov_perc%) is less than defined threshold (t=$threshold)"
    echo "$cov_summary"
  fi
}

start_time=$(date +%s)

step "Generating localization files" \
     "Please ensure all .arb files are valid" \
     flutter gen-l10n

step "Auto-formatting generated localization files" \
     "" \
     dart format --line-length=100 lib/l10n

step "Checking code formatting with dart format" \
     "Please run 'dart format . --line-length=100' to format your code" \
     dart format --line-length=100 --set-exit-if-changed .

step "Running flutter analyze" \
     "Please fix all issues before committing" \
     flutter analyze

step "Running flutter test with coverage" \
     "Please fix all failing tests before committing" \
     timeout 30s flutter test --coverage -r failures-only

step "Running coverage report" \
     "Please increase test coverage before committing" \
     verify_coverage_at_least 55

step "Building APK" \
     "Please fix all build issues before committing" \
     flutter build apk

end_time=$(date +%s)

total_duration=$((end_time - start_time))
echo "✅ All checks passed! Total time: ${total_duration}s"
exit 0