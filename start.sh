#!/bin/bash
set -e

echo "=== Starting Metasploit MCP Server Container ==="

# Start PostgreSQL
echo "Starting PostgreSQL..."
service postgresql start
sleep 5

# Initialize PostgreSQL user and database for Metasploit
sudo -u postgres psql -c "CREATE USER msf WITH PASSWORD 'msf';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE msf OWNER msf;" 2>/dev/null || true

# Initialize Metasploit database
echo "Initializing Metasploit database..."
cd /opt/metasploit-framework
export PATH="/root/.rbenv/shims:/root/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Try to connect to database, initialize if needed
msfconsole -q -x "db_connect msf:msf@localhost/msf; db_status; exit" 2>/dev/null || \
msfconsole -q -x "db_connect msf:msf@localhost/msf; db_initialize; exit" || true

# Start msfrpcd in background
echo "Starting msfrpcd on port ${MSF_PORT}..."
cd /opt/metasploit-framework
msfrpcd -P "${MSF_PASSWORD}" -S -a 0.0.0.0 -p ${MSF_PORT} &
MSFRPCD_PID=$!

# Wait for msfrpcd to be ready
echo "Waiting for msfrpcd to start..."
for i in {1..30}; do
    if nc -z localhost ${MSF_PORT} 2>/dev/null; then
        echo "✓ msfrpcd is ready on port ${MSF_PORT}!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "✗ msfrpcd failed to start after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Start the MCP server
echo "Starting Metasploit MCP Server on port 8085..."
cd /app
exec python3.11 MetasploitMCP.py --transport http --host 0.0.0.0 --port 8085

