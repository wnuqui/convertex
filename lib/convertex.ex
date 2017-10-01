defmodule Convertex do
  @moduledoc """
  Convertex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Meeseeks.{CSS, XPath}
  import Ecto.Query, only: [from: 2]
  alias Convertex.{Repo, Conversion}

  @url "https://www.google.com/search?q=BASE+AMOUNT+to+TARGET"
  @ago_sec 60

  def fetch_cached_conversion(options) do
    ago = Timex.shift(Timex.now(), seconds: -ago_sec())

    query = from c in Conversion,
      where: \
      c.base == ^options["base"] and \
      c.amount == ^options["amount"] and \
      c.target == ^options["target"] and \
      c.inserted_at > ^ago

    Repo.one(query)
  end

  def convert_and_cache(options) do
    data = convert_via_google(options)

    attrs = %{
      base: options["base"],
      amount: options["amount"],
      target: options["target"],
      conversion_text: data
    }

    changeset = Conversion.changeset(%Conversion{}, attrs)

    Repo.insert changeset
  end

  def conversion_options(params) do
    amount = Map.get(params, "amount", "1")

    %{
      "base" => params["base"],
      "amount" => amount,
      "target" => params["target"]
    }
  end

  def ago_sec, do: @ago_sec

  defp convert_via_google(options) do
    url = @url
    |> String.replace("BASE", options["base"])
    |> String.replace("AMOUNT", options["amount"])
    |> String.replace("TARGET", options["target"])

    html = HTTPoison.get!(url).body

    html
    |> Meeseeks.all(xpath("//*[@id=\"ires\"]/ol/table"))
    |> hd()
    |> Meeseeks.all(css("b"))
    |> hd()
    |> Meeseeks.text()
  end
end
