defmodule ConvertexWeb.ConversionControllerTest do
  use ConvertexWeb.ConnCase, vcr: true

  import Ecto.Query

  import Mock

  alias Convertex.{Repo, Conversion}

  @conversion %{"conversion" => "1 US dollar = 51.0450 Philippine pesos"}

  def insert_conversion_in_the_past(seconds) do
    naive_datetime = Timex.shift(Timex.now, seconds: -seconds)
    |> DateTime.to_naive

    attrs = %{
      "base" => "USD",
      "amount" => "1",
      "target" => "PHP",
      "conversion_text" => "1 US dollar = 51.0450 Philippine pesos"
    }

    changeset = Conversion.changeset(%Conversion{inserted_at: naive_datetime, updated_at: naive_datetime}, attrs)

    Repo.insert! changeset
  end

  def invalid_conversion_changeset() do
    invalid_attrs = %{
      "base" => "INV",
      "amount" => "1",
      "target" => "PHP"
    }

    Conversion.changeset(%Conversion{}, invalid_attrs)
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
        count = conversion_count()
        post conn, "/api/conversions", base: "USD", amount: "1", target: "PHP"
        updated_count = conversion_count()

        assert count + 1 == updated_count
      end
    end

    test "does not create a conversion if a conversion is persisted for the last 60 seconds", %{conn: conn} do
      use_cassette "conversions/post" do
        insert_conversion_in_the_past (Convertex.ago_sec() - 10)
        count = conversion_count()

        post conn, "/api/conversions", base: "USD", amount: "1", target: "PHP"
        updated_count = conversion_count()

        assert count == updated_count
      end
    end

    test "creates a conversion if last conversion is persisted for more than 60 seconds already", %{conn: conn} do
      use_cassette "conversions/post" do
        insert_conversion_in_the_past (Convertex.ago_sec() + 10)
        count = conversion_count()

        post conn, "/api/conversions", base: "USD", amount: "1", target: "PHP"
        updated_count = conversion_count()

        assert count + 1 == updated_count
      end
    end

    test "fails to create a conversion as base and target are missing", %{conn: conn} do
      conn = post conn, "/api/conversions"

      errors = %{"base" => ["can't be blank"], "target" => ["can't be blank"]}
      assert json_response(conn, 422)["errors"] == errors
    end

    # TODO: Better way of doing test for this.
    test "fails to create a conversion since base is not a valid currency", %{conn: conn} do
      mocked = [
        conversion_changeset: fn(_) -> invalid_conversion_changeset() end,
        fetch_cached_conversion: fn(_) -> nil end,
        convert_and_cache: fn(_) -> {:error, "conversion error"} end
      ]

      with_mock Convertex, mocked do
        conn = post conn, "/api/conversions"
        assert json_response(conn, 422)["errors"] == "conversion error"
      end
    end
  end
end
