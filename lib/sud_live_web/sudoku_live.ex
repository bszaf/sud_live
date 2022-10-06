defmodule SudLiveWeb.SudokuLive do
  # In Phoenix v1.6+ apps, the line below should be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <.live_component module={SudLiveWeb.Components.Sudoku} id="sudoku" sudoku={@sudoku} check_result={@check_result} />
    """
  end

  def mount(_params, assigns, socket) do
    sudoku = Map.get(assigns, :sudoku, Sud.Board.new())

    socket =
      socket
      |> assign(:sudoku, sudoku)
      |> assign(:check_result, :none)

    {:ok, socket}
  end

  def handle_info({:update_message, message}, socket) do
    {:noreply, update(socket, :messages, fn messages -> [message | messages] end)}
  end

  def handle_event("validate", value, socket) do
    IO.inspect("validate")
    IO.inspect(value)
    {:noreply, socket}
  end

  def handle_event("cell_changed", value, socket) do
    case value do
      %{"_target" => ["sudoku", <<"r", row::binary-size(1), "c", col::binary-size(1)>> = cell_id]} ->
        value = value["sudoku"][cell_id]
        row = String.to_integer(row)
        col = String.to_integer(col)
        value = String.to_integer(value)

        socket = update(socket, :sudoku, fn board -> Sud.Board.set(board, row, col, value) end)
        {:noreply, socket}
    end
  end

  def handle_event("generate", _value, socket) do
    board = Sud.Generator.Classic.generate()
    {:noreply, assign(socket, :sudoku, board)}
  end

  def handle_event("check", _value, socket) do
    result = Sud.Board.validate(socket.assigns.sudoku)
    {:noreply, assign(socket, :check_result, result)}
  end
end
