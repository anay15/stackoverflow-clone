defmodule StackoverflowCloneWeb.Router do
  use StackoverflowCloneWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug StackoverflowCloneWeb.Plugs.CORSPlug, origin: ["http://localhost:3000", "http://127.0.0.1:3000"]
  end

  scope "/api", StackoverflowCloneWeb do
    pipe_through :api

    post "/search", SearchController, :search
    post "/re-rank", SearchController, :rerank
    get "/recent", SearchController, :recent
    get "/llm-status", SearchController, :llm_status
    
    # Handle OPTIONS requests for CORS
    options "/search", SearchController, :options
    options "/re-rank", SearchController, :options
    options "/recent", SearchController, :options
    options "/llm-status", SearchController, :options
    options "/*path", SearchController, :options
  end
end
