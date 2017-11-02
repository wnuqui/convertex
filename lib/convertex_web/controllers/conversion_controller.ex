defmodule ConvertexWeb.ConversionController do
  use ConvertexWeb, :controller

  def create(conn, params) do
    changeset = Convertex.conversion_changeset(params)

    if changeset.valid? do
      cached_conversion = Convertex.fetch_cached_conversion(changeset.changes)

      if cached_conversion != nil do
        render conn, "conversion.json", %{conversion: cached_conversion.conversion_text}
      else
        case Convertex.convert_and_cache(changeset) do
          {:ok, conversion} ->
            render conn, "conversion.json", %{conversion: conversion.conversion_text}
          {:error, _} ->
            conn
            |> put_status(422)
            |> render("failed_google_conversion.json", %{errors: "conversion error"})
        end
      end
    else
      conn
      |> put_status(422)
      |> render("422.json", %{changeset: changeset})
    end
  end
end
