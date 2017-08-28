defmodule ConvertexWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import ConvertexWeb.Router.Helpers
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

      # The default endpoint for testing
      @endpoint ConvertexWeb.Endpoint
    end
  end

  setup_all tags do
    if tags[:case] == ConvertexWeb.ConversionControllerTest do
      ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    end
    :ok
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Convertex.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Convertex.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
