require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "should not save without title" do
    j = Job.new
    assert_not j.save, "Saved Job without a title."
  end

  test "unique job title within company" do
    j = Job.new
    c = Company.new
    c.name = "company xyz"
    c.save
    j.title = "job xyz"
    j.company = Company.find_by(:name => "company xyz")
    j.save
    j1 = Job.new
    j1.title = "job xyz"
    j1.company = Company.find_by(:name => "company xyz")
    assert_not j1.save, "Saved job without unique title."
  end
  test "truth" do
    assert true
  end
end
