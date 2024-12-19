#!/bin/bash

# Nama branch tujuan dan sumber
TARGET_BRANCH="uat/feature/BTN-450/cardless-indomaret"
SOURCE_BRANCH="feature/BTN-450/cardless-indomaret"

# Keyword commit yang ingin diambil
KEYWORD="BTN-450(Cardless)"

# Pindah ke branch tujuan
echo "Switching to branch $TARGET_BRANCH..."
git checkout "$TARGET_BRANCH" || exit 1
git pull origin "$TARGET_BRANCH"

# Ambil semua commit yang sesuai dengan keyword, dari yang paling lama
echo "Fetching commits from $SOURCE_BRANCH with keyword '$KEYWORD'..."
COMMITS=$(git log "$SOURCE_BRANCH" --grep="$KEYWORD" --reverse --pretty=format:"%H")

if [ -z "$COMMITS" ]; then
  echo "No commits found with keyword '$KEYWORD'. Exiting..."
  exit 1
fi

# Loop untuk cherry-pick setiap commit dari yang pertama hingga terakhir
for COMMIT in $COMMITS; do
  echo "Cherry-picking commit $COMMIT..."
  
  # Cherry-pick commit dengan strategi 'theirs' untuk konflik
  git cherry-pick "$COMMIT" -X theirs || {
    echo "Conflict detected in commit $COMMIT. Resolving conflicts automatically..."
    git add . # Tambahkan semua file yang berubah
    git commit -m "Auto-resolved conflicts during cherry-pick of $COMMIT" || {
      echo "Failed to commit resolved conflicts for $COMMIT. Skipping..."
      git cherry-pick --abort
      continue
    }
  }
done

echo "Cherry-pick completed successfully!"