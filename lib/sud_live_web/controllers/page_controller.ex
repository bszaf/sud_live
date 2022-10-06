defmodule SudLiveWeb.PageController do
  use SudLiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
