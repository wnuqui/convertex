defmodule ConvertexWeb.ConversionControllerTest do
  use ConvertexWeb.ConnCase, vcr: true

  import Ecto.Query

  @conversion %{"conversion" => "1 US dollar = 51.0450 Philippine pesos"}

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
  end
end
