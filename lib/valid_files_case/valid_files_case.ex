defmodule Fast.ValidFilesCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Fast.ValidFilesCase
    end
  end

  def assert_files_valid(glob_path) do
    wildcard_path = Path.wildcard(glob_path)

    for file <- wildcard_path do
      try do
        file
        |> File.read!()
        |> Code.string_to_quoted!()
      catch
        :error, %SyntaxError{file: "nofile"} = e ->
          raise Map.put(e, :file, file)
      end
    end
  end

  def assert_files_exist(glob_path) do
    wildcard_path = Path.wildcard(glob_path)
    assert length(wildcard_path) > 0
  end

  def assert_no_files_exist(glob_path) do
    wildcard_path = Path.wildcard(glob_path)
    assert length(wildcard_path) == 0
  end
end
