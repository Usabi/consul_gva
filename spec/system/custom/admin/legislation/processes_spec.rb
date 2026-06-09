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

      within "fieldset", text: "Internal drafting phase" do
        check "Active"
        fill_in "Start", with: base_date - 3.days
        fill_in "End", with: base_date - 1.day
      end

      within "fieldset", text: "Process" do
        fill_in "Start", with: base_date
        fill_in "End", with: base_date + 5.days
        check "Active"
      end

      within "fieldset", text: "> Debate" do
        check "Active"
        fill_in "Start", with: base_date
        fill_in "End", with: base_date + 2.days
      end

      within "fieldset", text: "> Contributions to the draft" do
        check "Active"
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

    scenario "Legislation process in draft phase" do
      visit admin_root_path

      within("#side_menu") do
        click_button "Legislation"
        within("#legislation_menu") do
          click_link "Legislation"
        end
      end

      expect(page).not_to have_content "An example legislation process"

      click_link "New process"

      fill_in "Process Title", with: "An example legislation process in draft phase"
      fill_in "Summary", with: "Summary of the process"
      fill_in "Description", with: "Describing the process"

      base_date = Date.current - 2.days

      within "fieldset", text: "Internal drafting phase" do
        check "Active"
        fill_in "Start", with: base_date
        fill_in "End", with: base_date + 3.days
      end

      within "fieldset", text: "Process" do
        fill_in "Start", with: base_date
        fill_in "End", with: base_date + 5.days
        check "Active"
      end

      click_button "Create process"

      expect(page).to have_content "An example legislation process in draft phase"
      expect(page).to have_content "Process created successfully"

      click_link "Click to visit"

      expect(page).to have_content "An example legislation process in draft phase"
      expect(page).not_to have_content "Summary of the process"
      expect(page).to have_content "Describing the process"

      visit legislation_processes_path

      expect(page).not_to have_content "An example legislation process in draft phase"
      expect(page).not_to have_content "Summary of the process"
      expect(page).not_to have_content "Describing the process"
    end

    scenario "Create a legislation process with an image" do
      visit new_admin_legislation_process_path
      fill_in "Process Title", with: "An example legislation process"
      fill_in "Summary", with: "Summary of the process"

      base_date = Date.current

      within "fieldset", text: "Process" do
        fill_in "Start", with: base_date
        fill_in "End", with: base_date + 5.days
        check "Active"
      end

      imageable_attach_new_file(file_fixture("clippy.jpg"))

      click_button "Create process"

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Process created successfully"

      click_link "Click to visit"

      expect(page).to have_content "An example legislation process"
      expect(page).not_to have_content "Summary of the process"
      expect(page).to have_css("img[alt='An example legislation process']")
    end
  end

  context "Update" do
    let!(:process) do
      create(:legislation_process,
             title: "An example legislation process",
             summary: "Summarizing the process",
             description: "Description of the process")
    end

    scenario "Remove summary text" do
      visit admin_root_path

      within("#side_menu") do
        click_button "Legislation"
        within("#legislation_menu") do
          click_link "Legislation"
        end
      end

      within("tr", text: "An example legislation process") { click_link "Edit" }

      expect(page).to have_css "h2", text: "An example legislation process"
      expect(find("#legislation_process_debate_phase_enabled")).to be_checked
      expect(find("#legislation_process_published")).to be_checked

      fill_in "Summary", with: ""
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"

      visit legislation_processes_path
      expect(page).not_to have_content "Summarizing the process"
      expect(page).to have_content "Description of the process"
    end

    scenario "Deactivate draft publication" do
      visit admin_root_path

      within("#side_menu") do
        click_button "Legislation"
        within("#legislation_menu") do
          click_link "Legislation"
        end
      end

      within("tr", text: "An example legislation process") { click_link "Edit" }

      expect(find("#legislation_process_draft_publication_enabled")).to be_checked

      uncheck "legislation_process_draft_publication_enabled"
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"
      expect(find("#debate_start_date").value).not_to be_blank
      expect(find("#debate_end_date").value).not_to be_blank

      click_link "Click to visit"

      expect(page).not_to have_content "Draft publication"
    end

    scenario "Enabling comments phase with blank dates" do
      visit edit_admin_legislation_process_path(process)

      within "fieldset", text: "> Contributions to the draft" do
        check "Active"
        fill_in "Start", with: ""
        fill_in "End", with: ""
      end

      click_button "Save changes"

      expect(page).to have_content "errors prevented this process from being saved"

      within "fieldset", text: "> Contributions to the draft" do
        expect(page).to have_content "can't be blank"
      end
    end

    scenario "Change proposal categories" do
      visit edit_admin_legislation_process_path(process)
      within(".admin-content") { click_link "Proposals" }

      fill_in "Categories", with: "recycling,bicycles,pollution"
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"

      visit admin_legislation_process_proposals_path(process)

      expect(page).to have_field("Categories", with: "bicycles, pollution, recycling")

      within(".admin-content") { click_link "Info" }
      fill_in "Summary", with: "Summarizing the process"
      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"

      visit admin_legislation_process_proposals_path(process)

      expect(page).to have_field("Categories", with: "bicycles, pollution, recycling")
    end
  end

  context "Search form" do
    scenario "Searches processes by title" do
      create(:legislation_process, title: "Proceso de reciclaje")
      create(:legislation_process, title: "Proceso de movilidad")

      visit admin_legislation_processes_path
      fill_in "search", with: "reciclaje"
      click_button "Filter"

      expect(page).to have_content "Proceso de reciclaje"
      expect(page).not_to have_content "Proceso de movilidad"
    end

    scenario "Searches processes by id" do
      process = create(:legislation_process, title: "Proceso único")
      create(:legislation_process, title: "Otro proceso")

      visit admin_legislation_processes_path
      fill_in "search", with: process.id.to_s
      click_button "Filter"

      expect(page).to have_content "Proceso único"
      expect(page).not_to have_content "Otro proceso"
    end
  end

  context "SDG related list" do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.legislation"] = true
    end

    scenario "do not show SDG columns if disabled" do
      process = create(:legislation_process, title: "Legislation process with SDG related content")
      process.sdg_goals = [SDG::Goal[1], SDG::Goal[17]]

      Setting["feature.sdg"] = false

      visit admin_legislation_processes_path

      expect(page).not_to have_css "th", text: "Goals"
      expect(page).not_to have_css "th", text: "Targets"

      within "tr", text: "Legislation process with SDG related content" do
        expect(page).not_to have_content "1, 17"
      end
    end

    scenario "create Collaborative Legislation with sdg related list" do
      visit new_admin_legislation_process_path
      fill_in "Process Title", with: "Legislation process with SDG related content"

      within "fieldset", text: "Process" do
        fill_in "Start", with: 2.days.ago
        fill_in "End", with: 1.day.from_now
        check "Active"
      end

      click_sdg_goal(17)
      click_button "Create process"

      expect(page).to have_content "Process created successfully"

      visit admin_legislation_processes_path

      within("tr", text: "Legislation process with SDG related content") do
        expect(page).to have_css "td", exact_text: "17"
      end
    end
  end
end
