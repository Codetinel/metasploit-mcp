# Docker Deployment Guide

The easiest way to run Metasploit MCP Server is using Docker, which includes Metasploit Framework and all dependencies pre-configured.

## Building the Docker Image

Build the Docker image from the repository root:

```bash
docker build -t metasploit-mcp:latest .
```

This will:
- Use Kali Linux as the base image (includes Metasploit Framework)
- Install all Python dependencies
- Initialize the Metasploit database
- Set up the MCP server

## Running the Container

### Basic Usage

Run the container with port mapping:

```bash
docker run -d -p 8080:8080 --name metasploit-mcp metasploit-mcp:latest
```

This will:
- Start PostgreSQL for Metasploit database
- Initialize the Metasploit database
- Start msfrpcd (Metasploit RPC daemon)
- Start the MCP server on port 8080

### With Custom Password

Set a custom password for msfrpcd:

```bash
docker run -d -p 8080:8080 \
  -e MSF_PASSWORD=your_secure_password \
  --name metasploit-mcp \
  metasploit-mcp:latest
```

If you don't set `MSF_PASSWORD`, a random password will be generated and displayed in the container logs.

## Connecting to the MCP Server

Once the container is running, the MCP server is available at:

- **MCP SSE Endpoint**: `http://localhost:8080/sse`
- **API Documentation**: `http://localhost:8080/docs`
