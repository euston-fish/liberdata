defmodule Liberdata.CommandDocs do
  use Liberdata.Commands

  command(:ls, """
          ```
          code code code
          ```
          """)

  command(:foo, """
          anything in here
          """)
end
