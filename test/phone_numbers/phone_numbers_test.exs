defmodule Fast.PhoneNumbersTest do
  use ExUnit.Case

  # module under test
  alias Fast.PhoneNumbers

  describe inspect(&PhoneNumbers.format/1) do
    test "with nil" do
      assert PhoneNumbers.format(nil) == nil
    end

    test "with empty string" do
      assert PhoneNumbers.format("") == nil
    end

    test "with invalid phone number" do
      assert PhoneNumbers.format("11122233") == "11122233"
    end

    test "with valid phone number" do
      assert PhoneNumbers.format("5554443322") == "(555) 444-3322"
      assert PhoneNumbers.format("(555) 444-3322") == "(555) 444-3322"
      assert PhoneNumbers.format("(555) 444-3322 ") == "(555) 444-3322"
      assert PhoneNumbers.format("(555) 444-332 ") == "555444332"
      assert PhoneNumbers.format(" 5554443322") == "(555) 444-3322"
      assert PhoneNumbers.format("55544433223") == "55544433223"
      assert PhoneNumbers.format("15554443322") == "+1 (555) 444-3322"
    end
  end

  describe inspect(&PhoneNumbers.unformat/1) do
    test "with nil" do
      assert PhoneNumbers.unformat(nil) == nil
    end

    test "with empty string" do
      assert PhoneNumbers.unformat("") == nil
    end

    test "with phone number" do
      assert PhoneNumbers.unformat("(333) 111-3344") == "3331113344"
    end
  end

  describe inspect(&PhoneNumbers.valid?/1) do
    test "with nil" do
      refute PhoneNumbers.valid?(nil)
    end

    test "with empty string" do
      refute PhoneNumbers.valid?("")
    end

    test "with character string" do
      refute PhoneNumbers.valid?("invalid")
    end

    test "with incorrect length" do
      refute PhoneNumbers.valid?("(333) 222-111")
      refute PhoneNumbers.valid?("333222111")
      refute PhoneNumbers.valid?("(333) 222-11111")
      refute PhoneNumbers.valid?("33322211111")
    end

    test "with formatting" do
      assert PhoneNumbers.valid?("333-444-1111")
      assert PhoneNumbers.valid?("(333) 444-1111")
      assert PhoneNumbers.valid?("333.444.1111")
      assert PhoneNumbers.valid?("1 (333) 444-1111")
      assert PhoneNumbers.valid?("+1 (333) 444-1111")
      assert PhoneNumbers.valid?("+13334441111")
    end

    test "without formatting" do
      assert PhoneNumbers.valid?("3334441111")
      assert PhoneNumbers.valid?("13334441111")
    end
  end
end
