defmodule Convertex.Repo.Migrations.CreateConversions do
  use Ecto.Migration

  def change do
    create table(:conversions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :integer
      add :base, :string
      add :target, :string

      timestamps()
    end

  end
end
