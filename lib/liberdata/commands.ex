defmodule Liberdata.Commands do
  defstruct name: nil, docs: nil

  defmacro __using__(_module) do
    quote do
      import Liberdata.Commands
      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      @before_compile Liberdata.Commands
    end
  end

  defmacro cmd(args, rest_var, do: body) do
    quote do
      def apply([unquote_splicing(args) | unquote(rest_var)]) do
        (fn ->
          unquote(body)
        end).()
        |> case do
          {:ok, rows, rest} -> apply([rows | rest])
          {:ok, rows} -> apply([rows | unquote(rest_var)])
          {:err, msg} -> {:err, msg}
        end
      end
    end
  end
  defmacro cmd(args, do: body) do
    quote do
      cmd(unquote(args), rest) do
        unquote(body)
      end
    end
  end

  defmacro doc(name, docs) do
    quote do
      @commands %Liberdata.Commands{
        name: unquote(name),
        docs: unquote(docs)
      }
    end
  end

  defmacro opr(name, lhs_var, rhs_var, do: body) do
    quote do
      defp filter(["or", key, unquote(Atom.to_string(name)), value | rest]) do
        {f, rest} = filter(rest)
        func = fn unquote(lhs_var), unquote(rhs_var) ->
          unquote(body)
        end
        {
          &(func.(Liberdata.Row.get(&1, key), Liberdata.Decoder.convert_type(value)) or f.(&1)),
          rest
        }
      end
    end
  end

  defmacro __before_compile__(env) do
    html = Module.get_attribute(env.module, :commands)
    |> Enum.sort(fn attr1, attr2 -> attr1.name < attr2.name end)
    |> Enum.map(&format_command/1)
    |> Enum.join("---\n")
    |> Earmark.as_html!

    quote do
      def documentation() do
        unquote(html)
      end

      def apply([rows = %Liberdata.Rows{}]) do
        {:ok, rows}
      end

      def apply(_) do
        {:err, "Bad command sequence"}
      end

      defp filter(rest), do: {fn _ -> false end, rest}
    end
  end

  def format_command(command) do
    """
    # [`#{command.name}`](##{command.name})
    {: ##{command.name} }

    #{command.docs}
    """
  end
end
