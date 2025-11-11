require "rails_helper"

describe "Custom robots.txt" do
  scenario "uses the default sitemap for the default tenant" do
    visit "/robots.txt"

    expect(page).to have_content "Sitemap: #{app_host}/sitemap.xml"
  end

  scenario "uses a different sitemap for other tenants" do
    # Use unique schema name to avoid conflicts in parallel execution
    schema_name = "cyborgs_#{Time.now.to_i}_#{rand(1000)}"
    tenant = create(:tenant, schema: schema_name)

    with_subdomain(schema_name) do
      visit "/robots.txt"

      expect(page).to have_content "Sitemap: http://#{schema_name}.lvh.me:#{app_port}/tenants/#{schema_name}/sitemap.xml"
    end
  end
end
