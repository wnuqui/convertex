defmodule Convertex do
  @moduledoc """
  Convertex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Meeseeks.XPath

  alias Convertex.{Repo, Conversion}

  @url "https://www.google.com/search?q=BASE+AMOUNT+to+TARGET"

  def convert(options) do
    amount = Map.get(options, "amount", "1")

    url = @url
    |> String.replace("BASE", options["base"])
    |> String.replace("AMOUNT", amount)
    |> String.replace("TARGET", options["target"])

    html = HTTPoison.get!(url).body

    results = Meeseeks.all(html, xpath("//*[@id=\"ires\"]/ol/table"))
    result = results |> hd()
    tree = Meeseeks.tree result

    data = tree
    |> elem(2)
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(2)
    |> elem(2)
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(0)
    |> elem(2)
    |> Enum.at(0)

    changeset = Conversion.changeset(%Conversion{}, %{base: options["base"], amount: amount, target: options["target"]})

    case Repo.insert(changeset) do
      {:ok, conversion} ->
        data
      {:error, changeset} ->
        IO.puts changeset
        "Conversion error"
    end
  end
end
