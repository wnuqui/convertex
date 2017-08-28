defmodule Convertex do
  @moduledoc """
  Convertex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Meeseeks.{CSS, XPath}

  alias Convertex.{Repo, Conversion}

  @url "https://www.google.com/search?q=BASE+AMOUNT+to+TARGET"

  def convert(options) do
    amount = Map.get(options, "amount", "1")

    url = @url
    |> String.replace("BASE", options["base"])
    |> String.replace("AMOUNT", amount)
    |> String.replace("TARGET", options["target"])

    html = HTTPoison.get!(url).body

    data = html
    |> Meeseeks.all(xpath("//*[@id=\"ires\"]/ol/table"))
    |> hd()
    |> Meeseeks.all(css("b"))
    |> hd()
    |> Meeseeks.text()

    attrs = %{base: options["base"], amount: amount, target: options["target"]}
    changeset = Conversion.changeset(%Conversion{}, attrs)

    case Repo.insert(changeset) do
      {:ok, _} ->
        data
      {:error, _} ->
        "Conversion error"
    end
  end
end
