defmodule Fast.StringTest do
  use ExUnit.Case, async: true

  describe inspect(&Fast.String.titlecase/1) do
    test "handles nil" do
      assert nil == Fast.String.titlecase(nil)
    end

    test "empty string" do
      assert "" == Fast.String.titlecase("")
    end

    test "various strings" do
      assert "Paul Kalkbrenner Live - Zürich - 2022" ==
               Fast.String.titlecase("PAUL KALKBRENNER LIVE - ZÜRICH - 2022")

      assert "Jon Gautsch" == Fast.String.titlecase("jon gautsch")
    end
  end

  describe inspect(&Fast.String.inflect_title_acronyms/1) do
    test "handles nil" do
      assert nil == Fast.String.inflect_title_acronyms(nil)
    end

    test "empty string" do
      assert "" == Fast.String.inflect_title_acronyms("")
    end

    test "string with no acronyms" do
      assert "some string" == Fast.String.inflect_title_acronyms("some string")
    end

    test "strings with title acronyms" do
      assert "Jon MD" == Fast.String.inflect_title_acronyms("Jon md")
      assert "Jon MD" == Fast.String.inflect_title_acronyms("Jon MD")
      assert "Jon MD" == Fast.String.inflect_title_acronyms("Jon M.D.")
      assert "Jon MD." == Fast.String.inflect_title_acronyms("Jon M.D..")
      assert "Jon Jr MD" == Fast.String.inflect_title_acronyms("Jon Jr. M.D.")
      assert "Jon PhD" == Fast.String.inflect_title_acronyms("Jon PHD")
    end
  end

  describe inspect(&Fast.String.inflect_address_acronyms/1) do
    test "handles nil" do
      assert nil == Fast.String.inflect_address_acronyms(nil)
    end

    test "empty string" do
      assert "" == Fast.String.inflect_address_acronyms("")
    end

    test "string with no acronyms" do
      assert "some string" == Fast.String.inflect_address_acronyms("some string")
    end

    test "strings with address acronyms" do
      assert "Main St" == Fast.String.inflect_address_acronyms("Main Street")
      assert "Main St" == Fast.String.inflect_address_acronyms("Main street")
      assert "Main St" == Fast.String.inflect_address_acronyms("Main St.")
      assert "Main Ave" == Fast.String.inflect_address_acronyms("Main Avenue")
      assert "Main Ave, Suite 300" == Fast.String.inflect_address_acronyms("Main Avenue, Ste 300")
    end
  end

  describe inspect(&Fast.String.slugify/1) do
    test "handles nil" do
      assert nil == Fast.String.slugify(nil)
    end

    test "empty string" do
      assert "" == Fast.String.slugify("")
    end

    test "string with no symbols" do
      assert "some-string" == Fast.String.slugify("some string")
    end

    test "strings with symbols and spaces" do
      assert "spoon-and-fork.png" == Fast.String.slugify("Spoon & $ ,Fork.PNG")
    end
  end
end
