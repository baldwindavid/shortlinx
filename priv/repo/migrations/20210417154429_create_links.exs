defmodule Shortlinx.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add(:url, :string, null: false)
      add(:shortcode, :string, size: 6, null: false)
      add(:visits_count, :integer, default: 0, null: false)
      add(:last_visit_at, :utc_datetime)

      timestamps()
    end

    create(unique_index(:links, [:shortcode]))
  end
end
