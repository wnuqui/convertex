defmodule ConvertexWeb.ConversionView do
  use ConvertexWeb, :view

  def render("conversion.json", %{conversion: conversion}) do
    %{data: %{conversion: conversion}}
  end
end
