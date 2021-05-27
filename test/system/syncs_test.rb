require "application_system_test_case"

class SyncsTest < ApplicationSystemTestCase
  setup do
    @sync = syncs(:one)
  end

  test "visiting the index" do
    visit syncs_url
    assert_selector "h1", text: "Syncs"
  end

  test "creating a Sync" do
    visit syncs_url
    click_on "New Sync"

    fill_in "User", with: @sync.user_id
    click_on "Create Sync"

    assert_text "Sync was successfully created"
    click_on "Back"
  end

  test "updating a Sync" do
    visit syncs_url
    click_on "Edit", match: :first

    fill_in "User", with: @sync.user_id
    click_on "Update Sync"

    assert_text "Sync was successfully updated"
    click_on "Back"
  end

  test "destroying a Sync" do
    visit syncs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Sync was successfully destroyed"
  end
end
