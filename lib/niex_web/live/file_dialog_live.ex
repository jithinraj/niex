defmodule NiexWeb.FileDialogLive do
  use NiexWeb, :live_view

  def mount(_params, session, socket) do
    wd = File.cwd!()
    socket.assigns

    {:ok,
     assign(socket,
       selected: nil,
       working_directory: wd,
       title: session["title"],
       mode: session["mode"],
       reply: session["reply"],
       extensions: session["extensions"],
       paths: link_path(wd),
       filename: "Untitled",
       files: files(socket, wd, session["extensions"])
     )}
  end

  def handle_event("cancel", %{}, socket) do
    reply = String.to_atom(socket.assigns[:reply])
    send(socket.parent_pid, {reply, nil})
    {:noreply, assign(socket, show_file_dialog: false)}
  end

  def handle_event("open", %{}, socket) do
    reply = String.to_atom(socket.assigns[:reply])
    send(socket.parent_pid, {reply, socket.assigns[:selected]})
    {:noreply, assign(socket, show_file_dialog: false)}
  end

  def handle_event("save", %{}, socket) do
    reply = String.to_atom(socket.assigns[:reply])

    send(
      socket.parent_pid,
      {reply, Path.join(socket.assigns[:selected], socket.assigns[:filename])}
    )

    {:noreply, assign(socket, show_file_dialog: false)}
  end

  def handle_event("update-filename", %{filename: filename}, socket) do
    {:noreply, assign(socket, filename: filename)}
  end

  def handle_event("select", %{"path" => path}, socket) do
    path = Jason.decode!(path)
    {:ok, stat} = File.stat(path)
    select_path(stat.type, path, socket)
  end

  def select_path(:directory, path, socket) do
    {:noreply,
     assign(socket,
       selected: nil,
       working_directory: path,
       paths: link_path(path),
       files: files(socket, path, socket.assigns[:extensions])
     )}
  end

  def select_path(:regular, path, socket) do
    socket = assign(socket, selected: path)

    {:noreply,
     assign(socket,
       files: files(socket, socket.assigns[:working_directory], socket.assigns[:extensions])
     )}
  end

  def files(socket, path, extensions) do
    files =
      File.ls!(path)
      |> Enum.map(fn file ->
        filepath = Path.join(path, file)
        {:ok, stat} = File.stat(filepath)

        selectable = stat.type == :directory || Enum.find(extensions, &(&1 == Path.extname(file)))
        {file, Jason.encode!(filepath), selectable, filepath == socket.assigns[:selected]}
      end)
  end

  def handle_event(other, params, socket) do
    IO.inspect(other)
    IO.inspect(params)
    {:noreply, socket}
  end

  defp link_path(wd) do
    components_with_paths(Path.split(wd), Enum.at(Path.split(wd), 0), separator)
  end

  defp components_with_paths([component | rest], root, separator) do
    dir = Path.join(root, component)
    name = if(component == separator, do: component, else: component <> separator)
    [{name, Jason.encode!(dir)} | components_with_paths(rest, dir, separator)]
  end

  defp components_with_paths([], _, _) do
    []
  end

  defp separator do
    separator = Enum.at(Path.split(File.cwd!()), 0)
  end
end
