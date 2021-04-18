defmodule Shortlinx.LinkMgmt do
  import Ecto.Query, warn: false

  alias Shortlinx.LinkMgmt.Link
  alias Shortlinx.Repo

  @doc """
  Subscribes to broadcasts for the given link.
  """
  def subscribe(%Link{} = link) do
    Phoenix.PubSub.subscribe(Shortlinx.PubSub, topic(link))
  end

  @doc """
  Gets a link for the given ID.
  """
  def get_link!(id) do
    Repo.get!(Link, id)
  end

  @doc """
  Gets a link for the given shortcode.
  """
  def get_link_by_shortcode(shortcode) do
    Repo.get_by(Link, shortcode: shortcode)
  end

  @doc """
  Returns a new link with a pre-generated shortcode.
  """
  def new_link do
    %Link{
      shortcode: Link.generate_shortcode()
    }
  end

  @doc """
  Creates a new link with the given attributes.
  """
  def create_link(attrs \\ %{}) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns a changeset for the given link.
  """
  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end

  @doc """
  Updates the link with the attributes.
  """
  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes the given link.
  """
  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  @doc """
  Increments the visit count for the given link and sets the last visit to the current
  time. It also broadcasts the visit to subscribers of the link topic.
  """
  def increment_visit_count(%Link{} = link) do
    {1, _} =
      from(link in Link, where: link.id == ^link.id)
      |> Repo.update_all(inc: [visits_count: 1], set: [last_visit_at: DateTime.utc_now()])

    Phoenix.PubSub.broadcast(Shortlinx.PubSub, topic(link), {:link_visited, link})
    {:ok, link}
  end

  defp topic(%Link{} = link), do: inspect(__MODULE__) <> ":" <> link.id
end
