defmodule ConvertexWeb.ConversionControllerTest do
  use ConvertexWeb.ConnCase, vcr: true

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
  end
end
