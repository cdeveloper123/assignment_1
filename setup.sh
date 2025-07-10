#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for Ruby
if ! command_exists ruby; then
  echo "[ERROR] Ruby is not installed. Please install Ruby before running this script."
  exit 1
fi

# Check for Bundler
echo "==> Checking for Bundler..."
if ! command_exists bundle; then
  echo "[ERROR] Bundler is not installed. Run: gem install bundler"
  exit 1
fi

# Check for Node.js
if ! command_exists node; then
  echo "[ERROR] Node.js is not installed. Please install Node.js before running this script."
  exit 1
fi

# Check for Yarn
if ! command_exists yarn; then
  echo "[ERROR] Yarn is not installed. Please install Yarn before running this script."
  exit 1
fi

# Check for SQLite3 (if using SQLite)
if grep -q 'sqlite3' Gemfile; then
  if ! command_exists sqlite3; then
    echo "[ERROR] SQLite3 is not installed. Please install SQLite3 before running this script."
    exit 1
  fi
fi

echo "==> Installing Ruby gems..."
bundle install || { echo "Bundle install failed!"; exit 1; }

echo "==> Installing JavaScript dependencies..."
yarn install || { echo "Yarn install failed!"; exit 1; }

echo "==> Setting up the database (drop, create, migrate, seed)..."
bin/rails db:drop db:create db:migrate db:seed || { echo "Database setup failed!"; exit 1; }

echo "==> (Optional) Precompiling assets..."
bin/rails assets:precompile || { echo "Asset precompilation failed!"; exit 1; }

echo "\n==> Setup complete!"
echo "You can now run the Rails server with:"
echo "  bin/rails server"
echo "\nDefault users:"
echo "  Admin:    admin@example.com / password123"
echo "  User:     user1@example.com / password123" 