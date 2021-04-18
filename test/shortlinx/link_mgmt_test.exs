defmodule Shortlinx.LinkMgmtTest do
  use Shortlinx.DataCase

  alias Shortlinx.LinkMgmt

  describe "links" do
    alias Shortlinx.LinkMgmt.Link

    @valid_attrs %{shortcode: "ShrtCd", url: "http://example.com"}
    @update_attrs %{shortcode: "uPDaTe", url: "http://updated.com"}
    @invalid_attrs %{shortcode: nil, url: nil}

    def link_fixture(attrs \\ %{}) do
      {:ok, link} =
        attrs
        |> Enum.into(@valid_attrs)
        |> LinkMgmt.create_link()

      link
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      result = LinkMgmt.get_link!(link.id)
      assert link.id == result.id
    end

    test "get_link_by_shortcode/1 returns the link with given shortcode" do
      link = link_fixture()
      result = LinkMgmt.get_link_by_shortcode(link.shortcode)
      assert link.id == result.id
    end

    test "new_link/0 returns a new link with a valid pre-generated shortcode" do
      assert %Link{shortcode: shortcode} = LinkMgmt.new_link()

      attrs = Map.merge(@valid_attrs, %{shortcode: shortcode})
      assert {:ok, _} = LinkMgmt.create_link(attrs)
    end

    test "create_link/1 with valid data creates a link" do
      assert {:ok, %Link{} = link} = LinkMgmt.create_link(@valid_attrs)

      # Query for link to get visits_count with default value
      link = LinkMgmt.get_link!(link.id)

      assert link.shortcode == "ShrtCd"
      assert link.url == "http://example.com"
      assert link.visits_count == 0
      assert is_nil(link.last_visit_at)
    end

    test "create_link/1 requires a URL and shortcode" do
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(@invalid_attrs)

      assert errors_on(changeset) == %{shortcode: ["can't be blank"], url: ["can't be blank"]}
    end

    test "create_link/1 requires shortcode with a length of 6 characters" do
      attrs = Map.merge(@valid_attrs, %{shortcode: "12345"})
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)
      assert %{shortcode: ["should be 6 character(s)"]} = errors_on(changeset)

      attrs = Map.merge(@valid_attrs, %{shortcode: "123456"})
      assert {:ok, %Link{}} = LinkMgmt.create_link(attrs)

      attrs = Map.merge(@valid_attrs, %{shortcode: "1234567"})
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)
      assert %{shortcode: ["should be 6 character(s)"]} = errors_on(changeset)
    end

    test "create_link/1 requires a shortcode with valid characters" do
      valid_shortcodes = ["aBc123", "_-=_-=", "a-1-A-"]

      Enum.each(valid_shortcodes, fn shortcode ->
        attrs = Map.merge(@valid_attrs, %{shortcode: shortcode})
        assert {:ok, %Link{}} = LinkMgmt.create_link(attrs)
      end)

      invalid_shortcodes = ["abc12>", "abc12.", "abc 12"]

      Enum.each(invalid_shortcodes, fn shortcode ->
        attrs = Map.merge(@valid_attrs, %{shortcode: shortcode})
        assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)

        assert %{shortcode: ["should only include letters, numbers, -, _, and ="]} =
                 errors_on(changeset)
      end)
    end

    test "create_link/1 requires a URL with a valid scheme" do
      attrs = Map.merge(@valid_attrs, %{url: "ftp://google.com"})
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)
      assert %{url: ["must include http:// or https://"]} = errors_on(changeset)

      attrs = %{shortcode: "httpgo", url: "http://google.com"}
      assert {:ok, %Link{}} = LinkMgmt.create_link(attrs)

      attrs = %{shortcode: "httpsg", url: "https://google.com"}
      assert {:ok, %Link{}} = LinkMgmt.create_link(attrs)
    end

    test "create_link/1 requires a URL with a hostname" do
      attrs = Map.merge(@valid_attrs, %{url: "http://"})
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)
      assert %{url: ["must include a host (ex. google.com)"]} = errors_on(changeset)
    end

    test "create_link/1 requires a valid hostname" do
      attrs = Map.merge(@valid_attrs, %{url: "http://.google"})
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)
      assert %{url: ["must include a host (ex. google.com)"]} = errors_on(changeset)

      attrs = Map.merge(@valid_attrs, %{url: "http://google."})
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)
      assert %{url: ["must include a host (ex. google.com)"]} = errors_on(changeset)

      attrs = Map.merge(@valid_attrs, %{url: "http://googlecom"})
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(attrs)
      assert %{url: ["must include a host (ex. google.com)"]} = errors_on(changeset)
    end

    test "create_link/1 must be a unique shortcode" do
      assert {:ok, %Link{}} = LinkMgmt.create_link(@valid_attrs)
      assert {:error, %Ecto.Changeset{} = changeset} = LinkMgmt.create_link(@valid_attrs)
      assert %{shortcode: ["has already been taken"]} = errors_on(changeset)
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = LinkMgmt.change_link(link)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      assert {:ok, %Link{} = link} = LinkMgmt.update_link(link, @update_attrs)
      assert link.shortcode == "uPDaTe"
      assert link.url == "http://updated.com"
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = LinkMgmt.update_link(link, @invalid_attrs)
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = LinkMgmt.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> LinkMgmt.get_link!(link.id) end
    end

    test "record_visit/1 increments the visit count by 1" do
      link = link_fixture()

      link = LinkMgmt.get_link!(link.id)
      assert link.visits_count == 0
      assert is_nil(link.last_visit_at)

      LinkMgmt.record_visit(link)

      link = LinkMgmt.get_link!(link.id)
      assert link.visits_count == 1
      refute is_nil(link.last_visit_at)
    end
  end
end
