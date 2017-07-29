defmodule Liberdata.Commands do
  defstruct name: nil, docs: nil

  defmacro __using__(_module) do
    quote do
      import Liberdata.Commands
      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      @before_compile Liberdata.Commands
    end
  end

  defmacro command(name, docs) do
    quote do
      @commands %Liberdata.Commands{
        name: unquote(name),
        docs: unquote(docs)
      }
    end
  end

  defmacro __before_compile__(env) do
    commands = Module.get_attribute(env.module, :commands)
    IO.inspect commands

    html = Enum.map(commands, &format_command/1)
    |> Enum.join("---\n")
    |> Earmark.as_html!

    quote do
      def documentation() do
        unquote(html)
      end
    end
  end

  def format_command(command) do
    """
    # [`#{command.name}`](##{command.name})
    {: ##{command.name} }

    #{command.docs}
    </div>
    """
  end
end
