# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     StackoverflowClone.Repo.insert!(%StackoverflowClone.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias StackoverflowClone.Repo
alias StackoverflowClone.Search

# Insert some example recent searches
example_searches = [
  "how to reverse a list in elixir",
  "react hooks useState useEffect",
  "python list comprehension",
  "javascript async await",
  "docker compose vs dockerfile"
]

for query <- example_searches do
  %Search{}
  |> Search.changeset(%{query: query})
  |> Repo.insert!()
end

IO.puts("Seeded #{length(example_searches)} example searches")
