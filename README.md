# Stack Overflow Clone

A Stack Overflow search interface with AI-powered answer ranking using Ollama.

## Setup

### Option 1: Docker Setup

```bash
# 1. Install Ollama
brew install ollama  # macOS
# or
curl -fsSL https://ollama.ai/install.sh | sh  # Linux

# 2. Start Ollama and pull model
ollama serve
ollama pull llama3  # in another terminal

# 3. Set environment variables
cp env.example .env
# Edit .env and set:
# OLLAMA_URL=http://localhost:11434
# OLLAMA_MODEL=llama3

# 4. Start with Docker
make dev
```

### Option 2: Manual Setup

```bash
# 1. Install Ollama
brew install ollama  # macOS
# or
curl -fsSL https://ollama.ai/install.sh | sh  # Linux

# 2. Start Ollama and pull model
ollama serve
ollama pull llama3  # in another terminal

# 3. Set environment variables
export OLLAMA_URL="http://localhost:11434"
export OLLAMA_MODEL="llama3"

# 4. Install dependencies and start
cd backend && mix deps.get && mix phx.server
cd frontend && npm install && npm start  # in another terminal
```

### 5. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:4000

## Environment Variables

Create a `.env` file with these required variables:

```bash
# Database
DATABASE_URL=ecto://postgres:postgres@localhost:5432/stackoverflow_clone_dev

# Stack Exchange API (optional - for higher rate limits)
STACKEXCHANGE_KEY=your_stackexchange_key_here

# Ollama Configuration (required for AI ranking)
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=llama3

# Phoenix
PHX_HOST=localhost
PORT=4000

# React
REACT_APP_API_URL=http://localhost:4000
```

## Requirements

- Docker and Docker Compose
- Ollama installed and running
- Ports 3000, 4000, 5432, and 11434 available