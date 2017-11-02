defmodule Convertex.Conversion do @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Convertex.Conversion

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "conversions" do
    field :amount, :integer
    field :base, :string
    field :target, :string
    field :conversion_text, :string

    timestamps()
  end

  @doc false
  def changeset(%Conversion{} = conversion, attrs) do
    conversion
    |> cast(attrs, [:amount, :base, :target])
    |> validate_required([:amount, :base, :target])
  end
end
