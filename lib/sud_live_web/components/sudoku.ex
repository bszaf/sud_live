defmodule SudLiveWeb.Components.Sudoku do
  use SudLiveWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="sm:container table items-center">
      Current sudoku:
      <%= form_for :sudoku, "#", [
            id: "sudoku",
            phx_change: "validate",
            'x-data': "{selected_value: 0, selected_id: undefined}",
            autocomplete: "off"], fn f ->
      %>
        <%= for row <- 1..9 do %>
          <div class="flex flex-row flex-nowrap justify-center">
            <%= for col <- 1..9 do %>
                <.cell_component row={row} col={col} sudoku={@sudoku} form={f} />
            <% end %>
          </div>
        <% end %>

      <% end %>
      <div class=" flex justify-center">
        <button phx-click="generate" class="bg-transparent hover:bg-blue-500 text-blue-700 font-semibold hover:text-white py-2 px-4 border border-blue-500 hover:border-transparent rounded">
          Generate
          </button>
        <button phx-click="check" class="bg-transparent hover:bg-blue-500 text-blue-700 font-semibold hover:text-white py-2 px-4 border border-blue-500 hover:border-transparent rounded">
          Check
          </button>
      </div>
      <.check_component check_result={@check_result} />
    </div>
    """
  end

  defp cell_component(assigns) do
    class = get_cell_class(assigns)
    value = get_value(assigns)
    id = "r#{assigns.row}c#{assigns.col}"

    assigns =
      assigns
      |> assign(:value, value)

    ~H"""
    <div class={"box-border border-2 #{class}"}>
      <%= text_input @form, id,
      'x-init': "$watch('selected_value',
           (value) => {
             if ($data.selected_id != $el.id) {
               if ($el.value == value && value != 0) {
                 $el.classList.add('bg-slate-100');
               } else {
                 $el.classList.remove('bg-slate-100');
               }
             }
           })",
         'x-ref': "sudoku_#{id}",
         'x-on:keyup.up': "$refs['sudoku_r#{@row-1}c#{@col}'].focus()",
         'x-on:keyup.down': "$refs['sudoku_r#{@row+1}c#{@col}'].focus()",
         'x-on:keyup.left': "$refs['sudoku_r#{@row}c#{@col-1}'].focus()",
         'x-on:keyup.right': "$refs['sudoku_r#{@row}c#{@col+1}'].focus()",
         class: "box h-16 w-16 align-middle text-center text-2xl caret-transparent",
         'x-on:focus': "
           $el.classList.add('bg-slate-100');
           selected_id = $el.id;
           selected_value = $el.value;
         ",
         'x-on:blur': "$el.classList.remove('bg-slate-100')",
         'x-on:keypress': "
           key = $event.key;
           if (['1', '2', '3', '4', '5', '6', '7', '8', '9'].includes(key)) {
             $el.value=key;
             selected_value = $el.value;
             console.log($event);
             console.log('changed to', $el.value)
           }
      ",
         'x-mask:dynamic': "$input.startsWith('0') ? 'a' : '9'",
         phx_change: "cell_changed",
         value: @value
      %>
    </div>
    """
  end

  defp get_cell_class(%{row: row, col: col}) do
    [
      &top_border/2,
      &left_border/2,
      &right_border/2,
      &bottom_border/2
    ]
    |> Enum.reduce(
      [],
      fn decorator, acc ->
        [decorator.(row, col) | acc]
      end
    )
    |> Enum.intersperse(" ")
  end

  defp top_border(row, _) when row in [1, 4, 7], do: "border-t-gray-400"
  defp top_border(_, _), do: ""

  defp left_border(_, col) when col in [1, 4, 7], do: "border-l-gray-400"
  defp left_border(_, _), do: ""

  defp right_border(_, col) when col in [3, 6, 9], do: "border-r-gray-400"
  defp right_border(_, _), do: ""

  defp bottom_border(row, _) when row in [3, 6, 9], do: "border-b-gray-400"
  defp bottom_border(_, _), do: ""

  defp get_value(%{sudoku: sudoku, row: row, col: col}) do
    case Sud.Board.get(sudoku, row, col) do
      0 -> ""
      n -> n
    end
  end

  defp check_component(assigns) do
    {class, text} =
      case assigns.check_result do
        true -> {"bg-green-400", "valid"}
        false -> {"bg-red-400", "wrong"}
        :none -> {"hidden", ""}
      end

    assigns = assigns |> assign(:class, class) |> assign(:text, text)

    ~H"""
        <div class={"box h-16 w-128 align-middle text-center text-2xl #{@class}"}>
          <%= @text %>
      </div>
    """
  end
end
