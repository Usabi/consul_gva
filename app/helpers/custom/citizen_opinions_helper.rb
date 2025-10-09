module Custom::CitizenOpinionsHelper
  def topics_options
    TOPIC_GROUPS.map do |group_key, topics|
      [
        t("citizen_opinions.form.topic.groups.#{group_key}"),
        topics.map { |topic_key| [t("citizen_opinions.form.topic.options.#{topic_key}"), topic_key.to_s] }
      ]
    end
  end

  private

    TOPIC_GROUPS = {
      general: [:suggestions, :public_employment, :others],
      social_services: [:dependency, :disability, :large_families, :childhood, :inclusion_income,
                        :other_social_services, :housing_rental, :housing_purchase, :subsidized_housing,
                        :housing_registry, :housing_renovation],
      treasury: [:economy, :taxes],
      justice: [:associations, :legal_aid, :common_law_marriages, :other_justice_issues,
                :civil_registry_Alcoy, :civil_registry_Alzira, :civil_registry_Benidorm,
                :civil_registry_Carlet, :civil_registry_Castello, :civil_registry_Catarroja,
                :civil_registry_Dénia, :civil_registry_Elda, :civil_registry_Elche,
                :civil_registry_Gandia, :civil_registry_Ibi, :civil_registry_Villajoyosa,
                :civil_registry_Lliria, :civil_registry_Massamagrell, :civil_registry_Mislata,
                :civil_registry_Moncada, :civil_registry_Novelda, :civil_registry_Nules,
                :civil_registry_Ontinyent, :civil_registry_Orihuela, :civil_registry_Paterna,
                :civil_registry_Picassent, :civil_registry_Quart, :civil_registry_Requena,
                :civil_registry_Sagunto, :civil_registry_San_Vicente, :civil_registry_Segorbe,
                :civil_registry_Sueca, :civil_registry_Torrent, :civil_registry_Torrevieja,
                :civil_registry_Vila_real, :civil_registry_Villena, :civil_registry_Vinaros,
                :civil_registry_Xativa, :exclusive_civil_registry_1_Alicante,
                :exclusive_civil_registry_1_Valencia, :exclusive_civil_registry_2_Alicante,
                :exclusive_civil_registry_2_Valencia, :exclusive_civil_registry_3_Valencia],
      health: [:healthcare],
      education: [:education, :valencian, :social_economy, :work, :employment, :culture],
      environment: [:airports, :nautical_activities, :coasts, :roads, :ports, :transport,
                    :urban_planning, :territorial_policy, :environment],
      innovation: [:trade, :industry, :innovation, :AVI, :IVACE, :tourism],
      agriculture: [:agriculture],
      emergency: [:forest_fire_prevention, :entertainment]
    }.freeze
end
