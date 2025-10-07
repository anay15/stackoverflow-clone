#!/bin/bash

# Simple API test script
echo "Testing Stack Overflow Clone API..."

# Test search endpoint
echo "1. Testing search endpoint..."
curl -X POST http://localhost:4000/api/search \
  -H "Content-Type: application/json" \
  -d '{"query": "how to reverse a list in elixir"}' \
  -w "\nHTTP Status: %{http_code}\n\n"

# Test recent searches endpoint
echo "2. Testing recent searches endpoint..."
curl http://localhost:4000/api/recent \
  -w "\nHTTP Status: %{http_code}\n\n"

echo "API tests completed!"
