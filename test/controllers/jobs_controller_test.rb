require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  def setup
    @job = jobs(:job1)
  end

  def teardown
    @job = nil
  end

  test "should get index with all layouts" do
    get :index
    assert_response :success, "index did not load successfully"
    assert_not_nil assigns(:jobs)
    assert_template :index
    assert_template layout: "layouts/application"
    assert_template "jobs/_jobs_list"
    assert_template "jobs/_job"
  end

  test "should show job" do
    get :show, id: @job.id
    assert_response :success, "job posting was not shown"
    assert_template "jobs/_jumbotron_info"
    assert_template "jobs/_job_info"
  end
end
