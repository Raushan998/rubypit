#!/bin/bash

set -e

# Find all Ruby files in the project
files=$(find . -name '*.rb')

# Check each file with RuboCop
for file in $files; do
    echo "Checking $file"
    bundle exec rubocop "$file" # Run RuboCop with bundle exec

    if [ $? -eq 0 ]; then
        echo "✅ $file passed RuboCop checks."
    else
        echo "❌ $file failed RuboCop checks."
    fi
    echo "-----------------------------------"
done

echo "Rubocop check completed for all files."
