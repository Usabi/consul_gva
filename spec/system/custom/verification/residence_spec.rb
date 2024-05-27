require "rails_helper"

describe "Residence" do
  let(:other_data) do
    {
      name: 'Francisca',
      first_surname: 'Nomdedéu',
      last_surname: 'Camps',
      date_of_birth: '1977-10-19'.to_date,
      postal_code: '46100'
    }
  end

  let(:valid_body) do
    {
      datos_habitante: {
        "resultado" => true,
        "error" => false,
        "cod_estado" => "00",
        "literal_error" => "INFORMACION CORRECTA",
        "nacionalidad" => "ESPAÑA",
        "nombre" => "Francisca",
        "apellido1" => "Nomdedéu",
        "apellido2" => "Camps",
        "sexo" => "M",
        "fecha_nacimiento" => "19771019"
      },
      datos_vivienda: {
        "resultado" => true,
        "error" => false,
        "estado" => "0003",
        "literal" => "Verificación positiva. Ámbito Territorial de Residencia Correcto.",
      },
      datos_originales: other_data
    }
  end

  let(:invalid_age_body) do
    valid_body.merge({ datos_habitante: { "resultado" => false, "error" => 'error servicio edad' } })
  end

  let(:invalid_residence_body) do
    valid_body.merge({ datos_vivienda: { "resultado" => false, "estado" => '0233', "error" => 'error servicio residencia' } })
  end

  let(:unavailable_age_body) do
    valid_body.merge({ datos_habitante: { "resultado" => false, "error" => 'Servicio no disponible...' } })
  end

  let(:unavailable_residence_body) do
    valid_body.merge({ datos_vivienda: { "resultado" => false, "error" => 'Servicio no disponible...' } })
  end

  before do
    create(:geozone)
    expect_any_instance_of(CensusApi).to receive(:get_response_body).with('1', '12345678Z', other_data).and_return(valid_body)
  end

  scenario "Verify resident" do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link "Verify my account"

    fill_in "residence_name", with: "Francisca"
    fill_in "residence_first_surname", with: "Nomdedéu"
    fill_in "residence_last_surname", with: "Camps"
    fill_in "residence_document_number", with: "12345678Z"
    select "DNI", from: "residence_document_type"
    select_date "19-October-1977", from: "residence_date_of_birth"
    fill_in "residence_postal_code", with: "46100"
    select "Male", from: "residence_gender"
    check "residence_terms_of_service"
    click_button "Verify residence"

    expect(page).to have_content "Account verified"
  end

  scenario "Verify resident above 12 years", consul: true do
    user = create(:user)
    login_as(user)

    valid_body[:datos_originales][:date_of_birth] = 13.years.ago.to_date
    valid_body[:datos_habitante]['fecha_nacimiento'] = 13.years.ago.strftime('%Y%m%d')

    visit account_path
    click_link "Verify my account"

    fill_in "residence_name", with: "Francisca"
    fill_in "residence_first_surname", with: "Nomdedéu"
    fill_in "residence_last_surname", with: "Camps"
    fill_in "residence_document_number", with: "12345678Z"
    select "DNI", from: "residence_document_type"
    select_date 13.years.ago.strftime('%d-%B-%Y'), from: "residence_date_of_birth"
    fill_in "residence_postal_code", with: "46100"
    select "Male", from: "residence_gender"
    check "residence_terms_of_service"
    click_button "Verify residence"

    # We don't have english translations
    # flash appears as missing translation
    expect(page).to have_content "required_age_request_form"
    # Bottom message as string
    expect(page).to have_content "Required Age Verification Request"
  end

  scenario "Verify resident with foreign checked" do

    user = create(:user)
    login_as(user)

    valid_body[:datos_originales][:postal_code] = '46100'

    visit account_path
    click_link "Verify my account"

    fill_in "residence_name", with: "Francisca"
    fill_in "residence_first_surname", with: "Nomdedéu"
    fill_in "residence_last_surname", with: "Camps"
    fill_in "residence_document_number", with: "12345678Z"
    select "DNI", from: "residence_document_type"
    select_date "19-October-1977", from: "residence_date_of_birth"
    fill_in "residence_postal_code", with: "46100"
    check "residence_foreign_residence"
    select "Male", from: "residence_gender"
    check "residence_terms_of_service"
    click_button "Verify residence"

    expect(page).to have_content "Account verified"
  end

  context 'foreign residence' do
    before { expect_any_instance_of(CensusApi).to receive(:get_response_body).with('1', '12345678Z', other_data).and_return(invalid_residence_body) }

    scenario "Verify foreign resident", consul: true do

      user = create(:user)
      login_as(user)

      visit account_path
      click_link "Verify my account"

      fill_in "residence_name", with: "Francisca"
      fill_in "residence_first_surname", with: "Nomdedéu"
      fill_in "residence_last_surname", with: "Camps"
      fill_in "residence_document_number", with: "12345678Z"
      select "DNI", from: "residence_document_type"
      select_date "19-October-1977", from: "residence_date_of_birth"
      fill_in "residence_postal_code", with: "46100"
      check "residence_foreign_residence"
      select "Male", from: "residence_gender"
      check "residence_terms_of_service"
      click_button "Verify residence"

      # We don't have english translations
      # flash appears as missing translation
      expect(page).to have_content "foreign_residence_request_form"
      # Bottom message as string
      expect(page).to have_content "Foreign Residence Verification Request"
    end
  end

  scenario "Verify foreign resident above 12 years", consul: true do
    user = create(:user)
    login_as(user)
    Setting["min_age_to_participate"] = 12
    valid_body[:datos_originales][:postal_code] = "46100"
    valid_body[:datos_originales][:date_of_birth] = 13.years.ago.to_date
    valid_body[:datos_habitante]['fecha_nacimiento'] = 13.years.ago.strftime('%Y%m%d')

    visit account_path
    click_link "Verify my account"
    fill_in "residence_name", with: "Francisca"
    fill_in "residence_first_surname", with: "Nomdedéu"
    fill_in "residence_last_surname", with: "Camps"
    fill_in "residence_document_number", with: "12345678Z"
    select "DNI", from: "residence_document_type"
    select_date 13.years.ago.strftime('%d-%B-%Y'), from: "residence_date_of_birth"
    fill_in "residence_postal_code", with: "46100"
    check "residence_foreign_residence"
    select "Male", from: "residence_gender"
    check "residence_terms_of_service"
    click_button "Verify residence"

    # We don't have english translations
    # flash appears as missing translation
    expect(page).to have_content "required_age_foreign_residence_request_form"
    # Bottom message as string
    expect(page).to have_content "Required Age Foreign Residence Verification Request"
  end

  scenario "Error on residence", consul: true do
    user = create(:user)
    login_as(user)

    valid_body[:datos_originales][:postal_code] = '36100'

    visit account_path
    click_link "Verify my account"

    fill_in "residence_name", with: "Francisca"
    fill_in "residence_first_surname", with: "Nomdedéu"
    fill_in "residence_last_surname", with: "Camps"
    fill_in "residence_document_number", with: "12345678Z"
    select "DNI", from: "residence_document_type"
    select_date "19-October-1977", from: "residence_date_of_birth"
    fill_in "residence_postal_code", with: "36100"
    select "Male", from: "residence_gender"
    check "residence_terms_of_service"

    click_button "Verify residence"

    expect(page).to have_content(/\d errors? prevented the verification of your residence/)
    expect(page).to have_content("In order to be verified, you must be registered")
  end

  scenario "Error on foreign residence", consul: true do
    user = create(:user)
    login_as(user)

    valid_body[:datos_originales][:postal_code] = '36100'

    visit account_path
    click_link "Verify my account"

    fill_in "residence_name", with: "Francisca"
    fill_in "residence_first_surname", with: "Nomdedéu"
    fill_in "residence_last_surname", with: "Camps"
    fill_in "residence_document_number", with: "12345678Z"
    select "DNI", from: "residence_document_type"
    select_date "19-October-1977", from: "residence_date_of_birth"
    fill_in "residence_postal_code", with: "36100"
    check "residence_foreign_residence"
    select "Male", from: "residence_gender"
    check "residence_terms_of_service"

    click_button "Verify residence"

    expect(page).to have_content(/\d errors? prevented the verification of your residence/)
    expect(page).to have_content("In order to be verified, you must be registered")
  end
end


# require "rails_helper"

# describe "Residence" do
#   before { create(:geozone) }

#   scenario "Verify resident" do
#     user = create(:user)
#     login_as(user)

#     visit account_path
#     click_link "Verify my account"
#     fill_in "residence_name", with: Faker::Name.first_name
#     fill_in "residence_first_surname", with: Faker::Name.last_name
#     fill_in "residence_last_surname", with: Faker::Name.last_name
#     fill_in "residence_document_number", with: "12345678Z"
#     select "DNI", from: "residence_document_type"
#     select_date "31-December-1980", from: "residence_date_of_birth"
#     fill_in "residence_postal_code", with: "46001"
#     select "Male", from: "residence_gender"
#     check "residence_terms_of_service"
#     click_button "Verify residence"

#     expect(page).to have_content "Your account is already verified"
#   end

#   scenario "Verify resident throught RemoteCensusApi", :remote_census, consul: true do
#     user = create(:user)
#     login_as(user)
#     mock_valid_remote_census_response

#     visit account_path
#     click_link "Verify my account"

#     fill_in "residence_name", with: Faker::Name.first_name
#     fill_in "residence_first_surname", with: Faker::Name.last_name
#     fill_in "residence_last_surname", with: Faker::Name.last_name
#     fill_in "residence_document_number", with: "12345678Z"
#     select "DNI", from: "residence_document_type"
#     select_date "31-December-1980", from: "residence_date_of_birth"
#     fill_in "residence_postal_code", with: "28013"
#     select "Male", from: "residence_gender"
#     check "residence_terms_of_service"
#     click_button "Verify residence"

#     expect(page).to have_content "Your account is already verified"
#   end

#   scenario "Residence form use min age to participate" do
#     min_age = (Setting["min_age_to_participate"] = 16).to_i
#     underage = min_age - 1
#     user = create(:user)
#     login_as(user)

#     visit account_path
#     click_link "Verify my account"

#     expect(page).to have_select("residence_date_of_birth_1i",
#                                  with_options: [min_age.years.ago.year])
#     expect(page).not_to have_select("residence_date_of_birth_1i",
#                                      with_options: [underage.years.ago.year])
#   end

#   scenario "When trying to verify a deregistered account old votes are reassigned" do
#     erased_user = create(:user, document_number: "12345678Z", document_type: "1", erased_at: Time.current)
#     vote = create(:vote, voter: erased_user)
#     new_user = create(:user)

#     login_as(new_user)

#     visit account_path
#     click_link "Verify my account"

#     fill_in "residence_name", with: Faker::Name.first_name
#     fill_in "residence_first_surname", with: Faker::Name.last_name
#     fill_in "residence_last_surname", with: Faker::Name.last_name
#     fill_in "residence_document_number", with: "12345678Z"
#     select "DNI", from: "residence_document_type"
#     select_date "31-December-1980", from: "residence_date_of_birth"
#     fill_in "residence_postal_code", with: "46001"
#     select "Male", from: "residence_gender"
#     check "residence_terms_of_service"

#     click_button "Verify residence"

#     expect(page).to have_content "Your account is already verified"

#     expect(vote.reload.voter).to eq(new_user)
#     expect(erased_user.reload.document_number).to be_blank
#     expect(new_user.reload.document_number).to eq("12345678Z")
#   end

#   scenario "Error on verify" do
#     user = create(:user)
#     login_as(user)

#     visit account_path
#     click_link "Verify my account"

#     click_button "Verify residence"

#     expect(page).to have_content(/\d errors? prevented the verification of your residence/)
#   end

#   scenario "Error on postal code not in census" do
#     Setting["postal_codes"] = "00001:99999"
#     user = create(:user)
#     login_as(user)

#     visit account_path
#     click_link "Verify my account"

#     fill_in "residence_name", with: Faker::Name.first_name
#     fill_in "residence_first_surname", with: Faker::Name.last_name
#     fill_in "residence_last_surname", with: Faker::Name.last_name
#     fill_in "residence_document_number", with: "12345678Z"
#     select "DNI", from: "residence_document_type"
#     select "1997", from: "residence_date_of_birth_1i"
#     select "January", from: "residence_date_of_birth_2i"
#     select "1", from: "residence_date_of_birth_3i"
#     fill_in "residence_postal_code", with: "00000"
#     select "Male", from: "residence_gender"
#     check "residence_terms_of_service"

#     click_button "Verify residence"

#     expect(page).to have_content "Citizens from this postal code cannot participate"
#   end

#   scenario "Error on census" do
#     user = create(:user)
#     login_as(user)

#     visit account_path
#     click_link "Verify my account"

#     fill_in "residence_name", with: Faker::Name.first_name
#     fill_in "residence_first_surname", with: Faker::Name.last_name
#     fill_in "residence_last_surname", with: Faker::Name.last_name
#     fill_in "residence_document_number", with: "12345678X"
#     select "DNI", from: "residence_document_type"
#     select "1997", from: "residence_date_of_birth_1i"
#     select "January", from: "residence_date_of_birth_2i"
#     select "1", from: "residence_date_of_birth_3i"
#     fill_in "residence_postal_code", with: "46001"
#     select "Male", from: "residence_gender"
#     check "residence_terms_of_service"

#     click_button "Verify residence"
#     expect(page).to have_content "The Census was unable to verify your information"
#     expect(page).to have_content "Please confirm that your census details are correct by calling to City Council or visit one Citizen Support Office."
#   end

#   scenario "5 tries allowed" do
#     user = create(:user)
#     login_as(user)

#     visit account_path
#     click_link "Verify my account"

#     5.times do
#       fill_in "residence_name", with: Faker::Name.first_name
#       fill_in "residence_first_surname", with: Faker::Name.last_name
#       fill_in "residence_last_surname", with: Faker::Name.last_name
#       fill_in "residence_document_number", with: "12345678X"
#       select "DNI", from: "residence_document_type"
#       select "1997", from: "residence_date_of_birth_1i"
#       select "January", from: "residence_date_of_birth_2i"
#       select "1", from: "residence_date_of_birth_3i"
#       fill_in "residence_postal_code", with: "46001"
#       select "Male", from: "residence_gender"
#       check "residence_terms_of_service"

#       click_button "Verify residence"
#       expect(page).to have_content "The Census was unable to verify your information"
#       expect(page).to have_content "Please confirm that your census details are correct by calling to City Council or visit one Citizen Support Office."
#     end

#     click_button "Verify residence"
#     expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
#     expect(page).to have_current_path(account_path)

#     visit new_residence_path
#     expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
#     expect(page).to have_current_path(account_path)
#   end

#   scenario "Terms and conditions link" do
#     login_as(create(:user))

#     visit new_residence_path
#     click_link "the terms and conditions of access"

#     expect(page).to have_content "Terms and conditions of access of the Census"
#   end
# end
