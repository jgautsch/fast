defmodule Fast.Ecto.ChangesetTest do
  use ExUnit.Case

  defmodule Contact do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :phone
    end

    def changeset(schema \\ %Contact{}, params) do
      cast(schema, params, ~w(phone)a)
    end
  end

  describe "validate_phone_number/2" do
    test "with nil value" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: nil})
        |> Fast.Ecto.Changeset.validate_phone_number(:phone)

      assert cs.valid?

      cs =
        %Contact{}
        |> Contact.changeset(%{})
        |> Fast.Ecto.Changeset.validate_phone_number(:phone)

      assert cs.valid?
    end

    test "with invalid value" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "invalid"})
        |> Fast.Ecto.Changeset.validate_phone_number(:phone)

      refute cs.valid?

      assert errors_on(cs) == %{phone: ["invalid phone number"]}
    end

    test "with custom message" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "invalid"})
        |> Fast.Ecto.Changeset.validate_phone_number(:phone, message: "no good")

      refute cs.valid?

      assert errors_on(cs) == %{phone: ["no good"]}
    end

    test "with valid formatted number" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "(333) 222-3333"})
        |> Fast.Ecto.Changeset.validate_phone_number(:phone, message: "no good")

      assert cs.valid?
    end

    test "with valid unformatted number" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "3332223333"})
        |> Fast.Ecto.Changeset.validate_phone_number(:phone, message: "no good")

      assert cs.valid?
    end
  end

  describe "normalize_phone_number/2" do
    test "with invalid changeset" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "11122233"})
        |> Map.put(:valid?, false)

      assert Fast.Ecto.Changeset.normalize_phone_number(cs, :phone) == cs
    end

    test "with valid changeset" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "(111) 222-3333"})

      assert cs.changes.phone == "(111) 222-3333"

      cs = Fast.Ecto.Changeset.normalize_phone_number(cs, :phone)

      assert cs.changes.phone == "1112223333"
    end
  end

  describe inspect(&Fast.Ecto.Changeset.encode_www_form/2) do
    test "encodes text" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "funky: it+й"})
        |> Fast.Ecto.Changeset.encode_www_form([:phone])

      assert cs.changes.phone == "funky%3A+it%2B%D0%B9"

      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "normal"})
        |> Fast.Ecto.Changeset.encode_www_form([:phone])

      assert cs.changes.phone == "normal"
    end
  end

  describe inspect(&Fast.Ecto.Changeset.slugify/2) do
    test "slugifies text" do
      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "Spoon & $ ,Fork.PNG"})
        |> Fast.Ecto.Changeset.slugify([:phone])

      assert cs.changes.phone == "spoon-and-fork.png"

      cs =
        %Contact{}
        |> Contact.changeset(%{phone: "normal"})
        |> Fast.Ecto.Changeset.slugify([:phone])

      assert cs.changes.phone == "normal"
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
