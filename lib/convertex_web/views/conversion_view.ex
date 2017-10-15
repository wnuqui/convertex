defmodule ConvertexWeb.ConversionView do
  use ConvertexWeb, :view
  import Ecto.Changeset

  def render("conversion.json", %{conversion: conversion}) do
    %{data: %{conversion: conversion}}
  end

  def render("422.json", %{changeset: changeset}) do
    errors = traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%(#{key})", to_string(value))
      end)
    end)
    %{errors: errors}
  end

  def render("failed_google_conversion.json", %{errors: errors}) do
    %{errors: errors}
  end
end
