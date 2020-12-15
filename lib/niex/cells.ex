defmodule Niex.Cells do
  use Phoenix.LiveComponent

  def render(state, cell = %{"cell_type" => "markdown", "source" => source}, idx)
      when state.selected_cell == idx do
    Phoenix.HTML.raw("""
    <div class="cell markdown"  class="cell" tabindex='0' phx-value-ref="#{idx}">
      <form phx-change="update-content" phx-focus="focus-cell">
        <input type="hidden" name="index" value="#{idx}" />
        <input type="hidden" name="cell_type" value="markdown" />
        <textarea phx-value-ref="#{idx}" phx-blur="blur-cell" phx-focus="focus-cell" name="text" phx-hook="NiexEditor" id="cell-text-#{
      idx
    }">#{source}</textarea>
        <div class="toolbar">
          <button class="run" phx-disable-with="Running..." type="submit">
            <i class="fas fa-play"></i>
          </button>
          <button class="remove" phx-disable-with="Removing...">
            <i class="fas fa-trash"></i>
          </button>

      <select name="cell_type">
        <option value="code">Elixir Code</option>
        <option value="markdown">Text</option>
      </select>
    </form>
    </div>
    """)
  end

  def render(state, cell = %{"cell_type" => "markdown", "source" => source}, idx) do
    {:ok, html, _} = Earmark.as_html(Enum.join(source, "\n"))

    Phoenix.HTML.raw("""
    <div class="cell markdown" phx-focus="focus-cell" phx-blur="blur-cell" class="cell" tabindex='0' phx-value-ref="#{
      idx
    }">
      #{html}
    </div>
    """)
  end

  def render(state, cell = %{"cell_type" => "code", "input" => input, "outputs" => outputs}, idx) do
    {:safe, submit} =
      Phoenix.HTML.Form.submit("Run", class_name: "run", phx_disable_with: "Executing...")

    Phoenix.HTML.raw("""
      <div class="cell" tabindex='0' phx-focus="focus-cell" phx-blur="blur-cell" phx-value-ref="#{
      idx
    }">
        <div class="cell-row">
          <span class="gutter">
            In [#{cell["prompt_number"]}]:
          </span>
        <span class="content">
          <form phx-submit="execute-cell" phx-change="update-content">
           <input type="hidden" name="index" value="#{idx}" />
           <input type="hidden" name="cell_type" value="code" />
          <textarea phx-value-ref="#{idx}" phx-hook="NiexCodeEditor" phx-focus="focus-cell" name="text" id="cell-code-#{
      idx
    }">#{Enum.join(input, "\n")}</textarea>
              <div class="toolbar">
          <button class="run" phx-disable-with="Running..." phx-click="execute-cell" phx-value-ref="#{
      idx
    }">
            <i class="fas fa-play"></i>
          </button>
          <button class="remove" phx-disable-with="Removing..." phx-click="remove-cell" phx-value-ref="#{
      idx
    }">
            <i class="fas fa-trash"></i>
          </button>

      <select name="cell_type">
        <option value="code">Elixir Code</option>
        <option value="markdown">Text</option>
      </select>
      </div>
      </form>

      </span>
      </div>
      <div class="cell-row">
        <span class="gutter">
          Out [#{cell["prompt_number"]}]:
        </span>
        <span class="content out">
            #{Enum.join(Enum.map(outputs, & &1["text"]), "\n")}
        </span>
        </div>
      </div>
    </pre>
    """)
  end

  def render(state, _, idx) do
    ""
  end
end
