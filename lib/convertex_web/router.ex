defmodule ConvertexWeb.Router do
  use ConvertexWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ConvertexWeb do
    pipe_through :api

    post "/conversions", ConversionController, :create
  end
end
