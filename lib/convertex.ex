defmodule Convertex do
  @moduledoc """
  Convertex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Meeseeks.{CSS, XPath}
  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  alias Convertex.{Repo, Conversion}

  @url "https://www.google.com/search?q=BASE+AMOUNT+to+TARGET"
  @ago_sec 60

  def conversion_changeset(params) do
    amount = Map.get(params, "amount")

    attrs =
      if is_nil(amount) do
        Map.put(params, "amount", "1")
      else
        params
      end

    Conversion.changeset(%Conversion{}, attrs)
  end

  def fetch_cached_conversion(options) do
    ago = Timex.shift(Timex.now(), seconds: -ago_sec())

    query = from c in Conversion,
      where: \
      c.base == ^options[:base] and \
      c.amount == ^options[:amount] and \
      c.target == ^options[:target] and \
      c.inserted_at > ^ago

    Repo.one(query)
  end

  def convert_and_cache(changeset) do
    conversion_text = convert_via_google(changeset.changes)
    changeset = changeset |> put_change(:conversion_text, conversion_text)
    Repo.insert changeset
  end

  def ago_sec, do: @ago_sec

  def convert_via_google(options) do
    url = @url
    |> String.replace("BASE", options[:base])
    |> String.replace("AMOUNT", to_string(options[:amount]))
    |> String.replace("TARGET", options[:target])

    html = HTTPoison.get!(url).body
    html = Meeseeks.all(html, xpath("//*[@id=\"ires\"]/ol/table"))

    case html do
      {:error, _} -> nil
      html ->
        html
        |> hd()
        |> Meeseeks.all(css("b"))
        |> hd()
        |> Meeseeks.text()
    end
  end
end
