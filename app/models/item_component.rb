class ItemComponent < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :component, polymorphic: true

  validates :owner, presence: true
  validates :component, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  # Ensure the unit is taken from the referenced component (Label, Container, RawMaterial, etc.)
  # If a unit is provided, it will be overwritten to keep consistency with the component definition.
  before_validation :assign_unit_from_component

  private

  def assign_unit_from_component
    return unless component.present?
    # copy unit from the component (component is an InventoryItem so responds to `unit`)
    self.unit = component.unit
  end
end
