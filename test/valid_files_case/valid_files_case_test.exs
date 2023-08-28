defmodule Fast.ValidFilesCaseTest do
  use Fast.ValidFilesCase

  test inspect(&assert_files_exist/1) do
    assert_files_exist("test/valid_files_case/**/*.exs")
    assert_files_exist("test/valid_files_case/valid_files/*.exs")
    assert_files_exist("test/valid_files_case/invalid_files/*.elixir")
  end

  test inspect(&assert_no_files_exist/1) do
    assert_no_files_exist("test/valid_files_case/**/*.ex")
    assert_no_files_exist("test/valid_files_case/valid_files/*.ex")
    assert_no_files_exist("test/valid_files_case/invalid_files/*.ex")
  end

  test inspect(&assert_files_valid/1) do
    assert_files_valid("test/valid_files_case/valid_files/*.exs")

    assert_raise SyntaxError, ~r/test\/valid_files_case\/invalid_files\/invalid.elixir:5:3/, fn ->
      assert_files_valid("test/valid_files_case/invalid_files/*.elixir")
    end
  end
end
