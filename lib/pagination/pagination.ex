defmodule Fast.Pagination do
  @default_max_page_size 100

  def paginate(args, fun, opts \\ []) do
    # First of all, don't let the user ask for a zillion records... 100 is max.
    # Second of all, ask for an extra 1 record, but then don't send it back to
    # the client. The presence of the extra 1 indicates that the end_of_list
    # hasn't been reached and there's more the user can ask to load.
    max_page_size = Keyword.get(opts, :max_page_size, @default_max_page_size)

    args =
      if args.first > max_page_size do
        Map.put(args, :first, max_page_size + 1)
      else
        Map.put(args, :first, args.first + 1)
      end

    with items when is_list(items) <- fun.(args) do
      end_of_list = length(items) < args.first
      items = Enum.take(items, args.first - 1)

      case items do
        [] ->
          {:ok, %{cursor: nil, items: items, end_of_list: end_of_list}}

        items when is_list(items) and length(items) > 0 ->
          extra_item = Enum.at(items, -1)
          cursor = get_cursor(extra_item, opts)

          {:ok, %{cursor: cursor, items: items, end_of_list: end_of_list}}
      end
    end
  end

  # This is a useful way to stream through pages without
  # requiring it to be inside a single transaction.
  # If
  def stream_pages(fun, opts \\ []) do
    Stream.resource(
      fn -> %{first: 100} end,
      fn
        :end_of_list ->
          {:halt, %{}}

        acc ->
          {:ok, page} = paginate(acc, fun, opts)

          next_acc =
            case page.end_of_list do
              true ->
                :end_of_list

              false ->
                Map.put(acc, :after, page.cursor)
            end

          {[page], next_acc}
      end,
      fn %{} -> %{} end
    )
  end

  def get_cursor(item, opts \\ []) do
    # NB: Yes, this could be written in a more "clever" way, but it's already funny
    #     enough with the function-as-option, so I'm intentionally writing it to
    #     be super explicit.
    case Access.get(opts, :get_cursor) do
      nil ->
        item.id

      fun ->
        fun.(item)
    end
  end
end
