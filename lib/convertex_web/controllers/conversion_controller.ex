defmodule ConvertexWeb.ConversionController do
  use ConvertexWeb, :controller
  import Convertex, only: [fetch_cached_conversion: 1, convert_and_cache: 1]

  alias Convertex.Conversion

  def create(conn, params) do
    changeset = Conversion.changeset(%Conversion{}, params)

    if changeset.valid? do
      cached_conversion = fetch_cached_conversion(changeset.changes)

      if is_nil(cached_conversion) do
        case convert_and_cache(changeset) do
          {:ok, conversion} ->
            render conn, "conversion.json", %{conversion: conversion.conversion_text}
          {:error, _} ->
            conn
            |> put_status(422)
            |> render("422.json", %{errors: "conversion error"})
        end
      else
        render conn, "conversion.json", %{conversion: cached_conversion.conversion_text}
      end
    else
      conn
      |> put_status(422)
      |> render("422.json", %{changeset: changeset})
    end
  end
end
