require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  test "should not save without name" do
    c = Company.new
    assert_not c.save, "Company saved without name."
  end

  test "should not save with same name" do
    c = Company.new
    c.name = "asdf"
    c.save
    c = Company.new
    c.name = "asdf"
    assert_not c.save, "companies saved with same name."
  end
end
