defmodule StackoverflowClone.Search do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :query, :inserted_at]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "recent_searches" do
    field :query, :string

    timestamps()
  end

  @doc false
  def changeset(search, attrs) do
    search
    |> cast(attrs, [:query])
    |> validate_required([:query])
    |> validate_length(:query, min: 1, max: 500)
  end
end
