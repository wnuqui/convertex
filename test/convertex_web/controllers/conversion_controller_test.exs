defmodule ConvertexWeb.ConversionControllerTest do
  use ConvertexWeb.ConnCase, vcr: true

  import Ecto.Query

  alias Convertex.{Repo, Conversion}

  @conversion %{"conversion" => "1 US dollar = 51.0450 Philippine pesos"}

  def insert_conversion_in_the_past(seconds) do
    naive_datetime = Timex.shift(Timex.now, seconds: -seconds)
    |> DateTime.to_naive

    attrs = %{
      base: "USD",
      amount: "1",
      target: "PHP",
      conversion_text: "1 US dollar = 51.0450 Philippine pesos"
    }

    changeset = Conversion.changeset(%Conversion{inserted_at: naive_datetime, updated_at: naive_datetime}, attrs)

    Repo.insert! changeset
  end

  def conversion_count do
    Convertex.Repo.one(from c in Convertex.Conversion, select: count(c.id))
  end

  describe "POST /api/conversions" do
    test "amount is present", %{conn: conn} do
      use_cassette "conversions/post" do
        conn = post conn, "/api/conversions", base: "USD", amount: "1", target: "PHP"
        assert json_response(conn, 200)["data"] == @conversion
      end
    end

    test "amount is nil", %{conn: conn} do
      use_cassette "conversions/post" do
        conn = post conn, "/api/conversions", base: "USD", target: "PHP"
        assert json_response(conn, 200)["data"] == @conversion
      end
    end

    test "creates a conversion if no conversion for the last 60 seconds", %{conn: conn} do
      use_cassette "conversions/post" do
        count = Convertex.Repo.one(from c in Convertex.Conversion, select: count(c.id))
        post conn, "/api/conversions", base: "USD", amount: "1", target: "PHP"
        updated_count = Convertex.Repo.one(from c in Convertex.Conversion, select: count(c.id))

        assert count + 1 == updated_count
      end
    end

    test "does not create a conversion if a conversion is persisted for the last 60 seconds", %{conn: conn} do
      use_cassette "conversions/post" do
        insert_conversion_in_the_past (Convertex.ago_sec() - 10)
        count = conversion_count()

        post conn, "/api/conversions", base: "USD", amount: "1", target: "PHP"
        updated_count = Convertex.Repo.one(from c in Convertex.Conversion, select: count(c.id))

        assert count == updated_count
      end
    end

    test "creates a conversion if last conversion is persisted for more than 60 seconds already", %{conn: conn} do
      use_cassette "conversions/post" do
        insert_conversion_in_the_past (Convertex.ago_sec() + 10)
        count = conversion_count()

        post conn, "/api/conversions", base: "USD", amount: "1", target: "PHP"
        updated_count = Convertex.Repo.one(from c in Convertex.Conversion, select: count(c.id))

        assert count + 1 == updated_count
      end
    end
  end
end
