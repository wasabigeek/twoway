require "application_system_test_case"

class SyncSourcesTest < ApplicationSystemTestCase
  setup do
    @sync_source = sync_sources(:one)
  end

  test "visiting the index" do
    visit sync_sources_url
    assert_selector "h1", text: "Sync Sources"
  end

  test "creating a Sync source" do
    visit sync_sources_url
    click_on "New Sync Source"

    fill_in "Calendar source", with: @sync_source.calendar_source_id
    fill_in "Sync", with: @sync_source.sync_id
    click_on "Create Sync source"

    assert_text "Sync source was successfully created"
    click_on "Back"
  end

  test "updating a Sync source" do
    visit sync_sources_url
    click_on "Edit", match: :first

    fill_in "Calendar source", with: @sync_source.calendar_source_id
    fill_in "Sync", with: @sync_source.sync_id
    click_on "Update Sync source"

    assert_text "Sync source was successfully updated"
    click_on "Back"
  end

  test "destroying a Sync source" do
    visit sync_sources_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Sync source was successfully destroyed"
  end
end
