require "rails_helper"

describe "Admin collaborative legislation", :admin do
  it_behaves_like "admin_milestoneable",
                  :legislation_process,
                  "admin_legislation_process_milestones_path"

  context "Index" do
    scenario "Displaying collaborative legislation" do
      process_1 = create(:legislation_process, title: "Process open")
      process_2 = create(:legislation_process, title: "Process for the future",
                                               start_date: Date.current + 5.days)
      process_3 = create(:legislation_process, title: "Process closed",
                                               start_date: Date.current - 10.days,
                                               end_date: Date.current - 6.days)

      visit admin_legislation_processes_path(filter: "active")

      expect(page).to have_content(process_1.title)
      expect(page).to have_content(process_2.title)
      expect(page).not_to have_content(process_3.title)

      visit admin_legislation_processes_path(filter: "all")

      expect(page).to have_content(process_1.title)
      expect(page).to have_content(process_2.title)
      expect(page).to have_content(process_3.title)
    end

    scenario "Processes are sorted by descending start date", :consul do
      process_1 = create(:legislation_process, title: "Process 1", start_date: Date.yesterday)
      process_2 = create(:legislation_process, title: "Process 2", start_date: Date.current)
      process_3 = create(:legislation_process, title: "Process 3", start_date: Date.tomorrow)

      visit admin_legislation_processes_path(filter: "all")

      expect(page).to have_content process_1.start_date
      expect(page).to have_content process_2.start_date
      expect(page).to have_content process_3.start_date

      expect(page).to have_content process_1.end_date
      expect(page).to have_content process_2.end_date
      expect(page).to have_content process_3.end_date

      expect(process_3.title).to appear_before(process_2.title)
      expect(process_2.title).to appear_before(process_1.title)
    end
  end

  context "Create" do
    scenario "Valid legislation process" do
      visit admin_root_path

      within("#side_menu") do
        click_button "Legislation"
        within("#legislation_menu") do
          click_link "Legislation"
        end
      end

      expect(page).not_to have_content "An example legislation process"

      click_link "New process"

      fill_in "Process Title", with: "An example legislation process"
      fill_in "Summary", with: "Summary of the process"
      fill_in "Description", with: "Describing the process"

      base_date = Date.current

      within "fieldset", text: "Draft phase" do
        check "Enabled"
        fill_in "Start", with: base_date - 3.days
        fill_in "End", with: base_date - 1.day
      end

      within_fieldset "Process" do
        fill_in "Start", with: base_date
        fill_in "End", with: base_date + 5.days
      end

      within_fieldset "Debate phase" do
        check "Enabled"
        fill_in "Start", with: base_date
        fill_in "End", with: base_date + 2.days
      end

      within_fieldset "Comments phase" do
        check "Enabled"
        fill_in "Start", with: base_date + 3.days
        fill_in "End", with: base_date + 5.days
      end

      check "legislation_process[draft_publication_enabled]"
      fill_in "Draft publication date", with: base_date + 3.days

      check "legislation_process[result_publication_enabled]"
      fill_in "Final result publication date", with: base_date + 7.days

      click_button "Create process"

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Process created successfully"
      expect(page).to have_content "A default question has been created for the preliminary consultation phase of this process."

      click_link "Click to visit"

      expect(page).to have_content "An example legislation process"
      expect(page).not_to have_content "Summary of the process"
      expect(page).to have_content "Describing the process"

      within(".legislation-process-list") do
        expect(page).to have_link text: "Debate"
        expect(page).to have_link text: "Comments"
      end

      visit legislation_processes_path

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Summary of the process"
      expect(page).not_to have_content "Describing the process"
    end
  end
end
