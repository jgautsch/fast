defmodule Fast.PaginationTest do
  use ExUnit.Case, async: true

  # Module under test
  alias Fast.Pagination

  defmodule Items do
    @items (for i <- 1..250 do
              %{id: i, cursor: i}
            end)

    def list_items(args) do
      %{first: first} = args

      case Map.get(args, :after) do
        nil ->
          @items
          |> Enum.take(first)

        cursor ->
          @items
          |> Enum.filter(&(&1.cursor > cursor))
          |> Enum.take(first)
      end
    end
  end

  describe inspect(&Pagination.paginate/3) do
    test "first page" do
      args = %{first: 20}

      assert {:ok, res} =
               Pagination.paginate(args, fn args ->
                 Items.list_items(args)
               end)

      assert %{cursor: 20, end_of_list: false, items: items} = res
      assert length(items) == 20

      for item <- items do
        assert item.id >= 1 && item.id <= 20
      end
    end

    test "second page" do
      args = %{first: 20, after: 20}

      assert {:ok, res} =
               Pagination.paginate(args, fn args ->
                 Items.list_items(args)
               end)

      assert %{cursor: 40, end_of_list: false, items: items} = res
      assert length(items) == 20

      for item <- items do
        assert item.id >= 21 && item.id <= 40
      end
    end

    test "last page" do
      args = %{first: 20, after: 240}

      assert {:ok, res} =
               Pagination.paginate(args, fn args ->
                 Items.list_items(args)
               end)

      assert %{cursor: 250, end_of_list: true, items: items} = res
      assert length(items) == 10

      for item <- items do
        assert item.id >= 241
      end
    end

    test "max page size (100)" do
      args = %{first: 150}

      assert {:ok, res} =
               Pagination.paginate(args, fn args ->
                 Items.list_items(args)
               end)

      assert %{cursor: 100, end_of_list: false, items: items} = res
      assert length(items) == 100

      for item <- items do
        assert item.id >= 1 && item.id <= 100
      end
    end
  end

  describe inspect(&Pagination.stream_pages/2) do
    test "yields pages of 100 records" do
      stream =
        Pagination.stream_pages(fn args ->
          Items.list_items(args)
        end)

      # NB: 250 records, 100 per page = 3 pages
      pages = Enum.into(stream, [])
      assert 3 == length(pages)

      assert [page1, page2, page3] = pages

      assert page1.cursor == 100
      assert page1.end_of_list == false
      assert length(page1.items) == 100

      for item <- page1.items do
        assert item.cursor >= 1 && item.cursor <= 100
      end

      assert page2.cursor == 200
      assert page2.end_of_list == false
      assert length(page2.items) == 100

      for item <- page2.items do
        assert item.cursor >= 101 && item.cursor <= 200
      end

      assert page3.cursor == 250
      assert page3.end_of_list == true
      assert length(page3.items) == 50

      for item <- page3.items do
        assert item.cursor >= 201 && item.cursor <= 250
      end
    end

    test "when there's a single page" do
      stream =
        Pagination.stream_pages(fn _args ->
          Items.list_items(%{first: 10})
        end)

      pages = Enum.into(stream, [])
      assert 1 == length(pages)
      assert [page] = pages

      assert %{
               cursor: 10,
               end_of_list: true,
               items: items
             } = page

      assert length(items) == 10
    end

    test "when there are no records" do
      stream =
        Pagination.stream_pages(fn _args ->
          []
        end)

      pages = Enum.into(stream, [])
      assert 1 = length(pages)
      assert [page] = pages

      assert page == %{
               cursor: nil,
               end_of_list: true,
               items: []
             }
    end
  end
end
