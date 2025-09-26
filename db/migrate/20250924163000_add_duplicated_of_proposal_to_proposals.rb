class AddDuplicatedOfProposalToProposals < ActiveRecord::Migration[7.0]
  def change
    add_reference :proposals, :duplicated_of_proposal, foreign_key: { to_table: :proposals }, index: true
  end
end
