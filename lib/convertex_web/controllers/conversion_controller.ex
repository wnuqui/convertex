defmodule ConvertexWeb.ConversionController do
  use ConvertexWeb, :controller
  import Convertex, only: [fetch_cached_conversion: 1, convert_and_cache: 1, conversion_options: 1]

  def create(conn, params) do
    options = conversion_options(params)
    cached_conversion = fetch_cached_conversion(options)

    if is_nil(cached_conversion) do
      case convert_and_cache(options) do
        {:ok, conversion} ->
          render conn, "conversion.json", %{conversion: conversion.conversion_text}
        {:error, _} ->
          "Conversion error"
      end
    else
      render conn, "conversion.json", %{conversion: cached_conversion.conversion_text}
    end
  end
end
