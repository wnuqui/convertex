defmodule Convertex.Repo.Migrations.UpdateConversionsTable do
  use Ecto.Migration

  def change do
    alter table(:conversions) do
      add :conversion_text, :string
   end
  end
end
