require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
    @non_activated_user = users(:lana)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert user.activated?
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_select 'a[href=?]', user_path(@non_activated_user), count: 0
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end
  
  test "show with/withiout activated to redirect" do
    log_in_as(@admin)
    users = User.all
    users.each do |user|
    get user_path(user)
      if user.activated?
        assert_template 'users/show'
      else
        assert_redirected_to root_url
      end
    end
  end
  

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
