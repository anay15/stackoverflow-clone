FROM elixir:1.15-alpine

# Install build dependencies
RUN apk add --no-cache build-base git

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=dev

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get
RUN mix deps.compile

# Copy source code
COPY . .

# Compile the application
RUN mix compile

# Expose port
EXPOSE 4000

# Start the server
CMD ["mix", "phx.server"]
