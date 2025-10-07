defmodule StackoverflowClone.Repo.Migrations.CreateRecentSearches do
  use Ecto.Migration

  def change do
    create table(:recent_searches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :query, :string, null: false

      timestamps()
    end

    create index(:recent_searches, [:inserted_at])
  end
end
