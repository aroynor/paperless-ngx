#!/bin/bash
# Duplicate File Finder and Cleanup Helper
# Safe script to find duplicates before installing Paperless-ngx
# example: ./find-duplicates.sh /myusbbak1/abbox/DocZ/

DOCS_DIR="${1:-$HOME/Documents}"

echo "🔍 Duplicate File Finder for Paperless-ngx Prep"
echo "================================================"
echo ""

# Check if fdupes is installed
if ! command -v fdupes &> /dev/null; then
    echo "❌ fdupes is not installed."
    echo "📦 Install it with: sudo apt install fdupes"
    echo ""
    exit 1
fi

echo "📂 Scanning directory: $DOCS_DIR"
echo ""
echo "⏳ Step 1: Finding duplicates (this may take a while)..."
echo ""

# Find duplicates and save to file
fdupes -r -S "$DOCS_DIR" > duplicates_report.txt

# Count duplicate groups
DUPLICATE_GROUPS=$(grep -c "^$" duplicates_report.txt)

if [ $DUPLICATE_GROUPS -eq 0 ]; then
    echo "✅ Great news! No duplicate files found."
    echo ""
    rm duplicates_report.txt
    exit 0
fi

echo "📊 Found duplicate file groups!"
echo ""
echo "📄 Report saved to: duplicates_report.txt"
echo ""

# Show summary
echo "📈 Summary:"
cat duplicates_report.txt | grep -E "bytes each|files"
echo ""

# Calculate space wasted
WASTED_SPACE=$(awk '/bytes each:/ {sum+=$1*($4-1)} END {print sum}' duplicates_report.txt)
WASTED_MB=$((WASTED_SPACE / 1024 / 1024))

echo "💾 Estimated wasted space: ${WASTED_MB} MB"
echo ""

# Ask user what to do
echo "What would you like to do?"
echo ""
echo "1) View the full report (duplicates_report.txt)"
echo "2) Delete duplicates interactively (you choose which to keep)"
echo "3) Exit and review manually"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        less duplicates_report.txt
        ;;
    2)
        echo ""
        echo "🗑️  Starting interactive deletion..."
        echo "💡 You'll be asked to select which files to keep"
        echo ""
        fdupes -r -d "$DOCS_DIR"
        echo ""
        echo "✅ Cleanup complete!"
        ;;
    3)
        echo ""
        echo "👍 Review the duplicates_report.txt file"
        echo "💡 When ready, run this script again and choose option 2"
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac

echo ""
echo "📄 Full report is saved in: duplicates_report.txt"
echo ""
