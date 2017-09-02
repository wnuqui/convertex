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

    attrs = %{
      base: options["base"],
      amount: amount,
      target: options["target"],
      conversion_text: data
    }

    changeset = Conversion.changeset(%Conversion{}, attrs)

    conversion = fetch_cached_conversion(attrs)

    if is_nil(conversion) do
      case Repo.insert(changeset) do
        {:ok, _} ->
          data
        {:error, _} ->
          "Conversion error"
      end
    else
      conversion.conversion_text
    end
  end

  def fetch_cached_conversion(attrs) do
    ago = Timex.now() |> Timex.shift(seconds: -ago_sec())

    query = from c in Conversion,
      where: \
      c.base == ^attrs[:base] and \
      c.amount == ^attrs[:amount] and \
      c.target == ^attrs[:target] and \
      c.inserted_at > ^ago

    Repo.one(query)
  end

  def ago_sec, do: @ago_sec
end
