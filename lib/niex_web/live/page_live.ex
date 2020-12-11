defmodule NiexWeb.PageLive do
  use NiexWeb, :live_view

  def mount(_params, _session, socket) do
    state = Niex.State.from_file("test_notebook.niex")
    {:ok, assign(socket, state: state)}
  end

  def handle_event("focus-cell", %{"ref" => ref}, socket) do
    {idx, _} = Integer.parse(ref)

    state =
      socket.assigns[:state]
      |> Niex.State.set_selected_cell(idx)

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("execute-cell", %{"cell_index" => cell_index, "command" => command}, socket) do
    {idx, _} = Integer.parse(cell_index)

    state =
      socket.assigns[:state]
      |> Niex.Notebook.execute_cell(idx, command)

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("blur-cell", data = %{"ref" => ref}, socket) do
    {idx, _} = Integer.parse(ref)

    state =
      socket.assigns[:state]
      |> Niex.State.set_selected_cell(nil)

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("update-markdown", data = %{"index" => index, "text" => value}, socket) do
    {idx, _} = Integer.parse(index)

    state =
      socket.assigns[:state]
      |> Niex.Notebook.update_cell(idx, %{"source" => [value]})

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("update-source", data = %{"index" => index, "text" => value}, socket) do
    {idx, _} = Integer.parse(index)

    state =
      socket.assigns[:state]
      |> Niex.Notebook.update_cell(idx, %{"input" => [value]})

    {:noreply, assign(socket, state: state)}
  end

  def handle_event("add-cell", %{"ref" => index}, socket) do
    index |> IO.inspect()
    {idx, _} = Integer.parse(index)
    {:noreply, assign(socket, state: Niex.Notebook.add_cell(socket.assigns[:state]))}
  end

  def handle_event("remove-cell", %{"ref" => index}, socket) do
    {idx, _} = Integer.parse(index)
    {:noreply, assign(socket, state: Niex.Notebook.remove_cell(socket.assigns[:state]))}
  end

  def handle_event("save", %{}, socket) do
    {:noreply, assign(socket, state: Niex.State.save(socket.assigns[:state]))}
  end

  def handle_event("update-title", %{"title" => title}, socket) do
    state = Niex.Notebook.update_metadata(socket.assigns[:state], %{"name" => title})

    {:noreply, assign(socket, state: state)}
  end

  def handle_event(event, other, socket) do
    IO.puts("Other event:")
    IO.inspect(event)
    IO.inspect(other)
    {:noreply, socket}
  end
end
