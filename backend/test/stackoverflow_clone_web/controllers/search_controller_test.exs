defmodule StackoverflowCloneWeb.SearchControllerTest do
  use StackoverflowCloneWeb.ConnCase, async: true

  alias StackoverflowClone.Search

  describe "POST /api/search" do
    test "returns success with valid query", %{conn: conn} do
      # Mock the Stack Exchange API response
      # In a real test, you'd use a library like ExVCR or mock the HTTP client
      conn = post(conn, ~p"/api/search", %{"query" => "elixir reverse list"})
      
      # Since we can't easily mock external APIs in this test,
      # we'll test the error handling path
      assert json_response(conn, 200)["success"] == true
    end

    test "returns error with empty query", %{conn: conn} do
      conn = post(conn, ~p"/api/search", %{"query" => ""})
      response = json_response(conn, 400)
      
      assert response["success"] == false
      assert response["error"] =~ "required"
    end

    test "returns error with missing query", %{conn: conn} do
      conn = post(conn, ~p"/api/search", %{})
      response = json_response(conn, 400)
      
      assert response["success"] == false
      assert response["error"] =~ "required"
    end
  end

  describe "POST /api/re-rank" do
    test "returns error with missing parameters", %{conn: conn} do
      conn = post(conn, ~p"/api/re-rank", %{})
      response = json_response(conn, 400)
      
      assert response["success"] == false
      assert response["error"] =~ "required"
    end

    test "returns success with valid parameters", %{conn: conn} do
      params = %{
        "question" => "How to reverse a list in Elixir?",
        "answers" => [
          %{
            "answer_id" => "123",
            "body" => "Use Enum.reverse/1",
            "score" => 5,
            "is_accepted" => true
          }
        ]
      }
      
      conn = post(conn, ~p"/api/re-rank", params)
      response = json_response(conn, 200)
      
      assert response["success"] == true
      assert is_list(response["ranked_answers"])
    end
  end

  describe "GET /api/recent" do
    test "returns recent searches", %{conn: conn} do
      # Insert a test search
      %Search{}
      |> Search.changeset(%{query: "test query"})
      |> Repo.insert!()

      conn = get(conn, ~p"/api/recent")
      response = json_response(conn, 200)
      
      assert response["success"] == true
      assert is_list(response["recent_searches"])
    end
  end
end
