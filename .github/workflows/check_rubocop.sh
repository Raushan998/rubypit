set -e
files=$(find . -name '*.rb')
for file in $files; do
    echo "Checking $file"
    rubocop $file

    # Check RuboCop exit code
    if [ $? -eq 0 ]; then
        echo "✅ $file passed RuboCop checks."
    else
        echo "❌ $file failed RuboCop checks."
    fi
    echo "-----------------------------------"
done

echo "Rubocop check completed for all files."
