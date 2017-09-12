defmodule ConvertexWeb.ConversionController do
  use ConvertexWeb, :controller

  def create(conn, params) do
    conversion = Convertex.convert conversion_params(params)
    render conn, "conversion.json", %{conversion: conversion}
  end

  defp conversion_params(params) do
    amount = Map.get(params, "amount", "1")

    %{
      "base" => params["base"],
      "amount" => amount,
      "target" => params["target"]
    }
  end
end
