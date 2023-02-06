defmodule Fast.Auth.DisposableEmailTest do
  use ExUnit.Case

  # module under test
  alias Fast.Auth.DisposableEmail

  test "is_disposable?/1" do
    assert DisposableEmail.is_disposable?("test@mailinator.com") == true
    assert DisposableEmail.is_disposable?("test@MAILINATOR.com") == true

    assert DisposableEmail.is_disposable?("test@gmail.com") == false

    assert DisposableEmail.is_disposable?(nil) == false
  end
end
