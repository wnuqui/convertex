defmodule ConvertexWeb.ConversionController do
  use ConvertexWeb, :controller

  def create(conn, params) do
    conversion = Convertex.convert params
    render conn, "conversion.json", %{conversion: conversion}
  end
end
