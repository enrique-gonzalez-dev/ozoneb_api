require 'test_helper'

class BranchTest < ActiveSupport::TestCase
  test 'should not save branch without name' do
    branch = Branch.new(branch_type: :production)
    assert_not branch.save, 'Saved the branch without a name'
  end

  test 'should not save branch without branch_type' do
    branch = Branch.new(name: 'Sucursal Central')
    assert_not branch.save, 'Saved the branch without a branch_type'
  end

  test 'should save valid branch' do
    branch = Branch.new(name: 'Sucursal Central', branch_type: :production)
    assert branch.save, 'Could not save a valid branch'
  end
end
