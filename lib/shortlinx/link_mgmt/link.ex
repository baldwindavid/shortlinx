defmodule Shortlinx.LinkMgmt.Link do
  use Shortlinx.Schema

  @shortcode_length 6
  @shortcode_regex ~r/^[a-zA-Z0-9\-=_]*$/
  @invalid_shortcode_error_msg "should only include letters, numbers, -, _, and ="
  @missing_scheme_error_msg "must include http:// or https://"
  @missing_host_error_msg "must include a host (ex. google.com)"

  schema "links" do
    field :shortcode, :string
    field :url, :string
    field :visits_count, :integer
    field :last_visit_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:url, :shortcode])
    |> validate_required([:url, :shortcode])
    |> validate_length(:shortcode, is: @shortcode_length)
    |> validate_format(:shortcode, @shortcode_regex, message: @invalid_shortcode_error_msg)
    |> validate_url()
    |> unique_constraint(:shortcode)
  end

  @doc """
  Returns a valid URL-encoded shortcode.
  """
  def generate_shortcode do
    :crypto.strong_rand_bytes(@shortcode_length)
    |> Base.url_encode64()
    |> binary_part(0, @shortcode_length)
  end

  # Basic URL validation only ensuring the presence of a valid scheme and host.
  # A conditional was chosen over regex for ease of changing requirements and
  # because the URL can be changed so easily post creation. A network call could
  # even be made to check the host for validity via :inet, though that side effect
  # would not belong in a changeset.
  defp validate_url(changeset) do
    validate_change(changeset, :url, fn :url, url ->
      %{scheme: scheme, host: host} = URI.parse(url)

      cond do
        is_nil(scheme) -> [url: @missing_scheme_error_msg]
        scheme not in ["http", "https"] -> [url: @missing_scheme_error_msg]
        is_nil(host) -> [url: @missing_host_error_msg]
        !String.contains?(host, ".") -> [url: @missing_host_error_msg]
        String.starts_with?(host, ".") -> [url: @missing_host_error_msg]
        String.ends_with?(host, ".") -> [url: @missing_host_error_msg]
        true -> []
      end
    end)
  end
end
