class CreateSiteCustomizationHelpTexts < ActiveRecord::Migration[4.2]
  def change
    create_table :site_customization_help_texts do |t|
      t.string :section, null: false
      t.string :locale

      t.timestamps null: false
    end

    add_index :site_customization_help_texts, :section, unique: true

    create_table :site_customization_help_text_translations do |t|
      t.references :site_customization_help_text, foreign_key: true,
                                                  null: false,
                                                  index: { name: "idx_help_text_translations" }
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :content

      t.index [:site_customization_help_text_id, :locale],
              unique: true,
              name: "index_help_text_translations_on_help_text_and_locale"
    end

    reversible do |dir|
      dir.up do
        [
          { section: "proposals",
            title: "Ayuda propuestas",
            content: "Contenido de Ayuda propuestas",
            locale: "es" },
          { section: "debates",
            title: "Ayuda debates",
            content: "Contenido de Ayuda debates",
            locale: "es" },
          { section: "polls",
            title: "Ayuda Votaciones",
            content: "Contenido de Ayuda Votaciones",
            locale: "es" },
          { section: "processes",
            title: "Ayuda Elaboración normativa",
            content: "Contenido de Ayuda Elaboración normativa",
            locale: "es" },
          { section: "budgets",
            title: "Ayuda presupuestos participativos",
            content: "Contenido de Ayuda presupuestos participativos",
            locale: "es" }
        ].each do |attrs|
          SiteCustomization::HelpText.find_or_create_by!(attrs)
        end

        [
          { site_customization_help_text_id: SiteCustomization::HelpText.find_by(section: "proposals").id,
            title: "Ajuda proposades",
            content: "Contingut d'Ajuda proposades",
            locale: "val" },
          { site_customization_help_text_id: SiteCustomization::HelpText.find_by(section: "debates").id,
            title: "Ajuda debats",
            content: "Contingut d'Ajuda debats",
            locale: "val" },
          { site_customization_help_text_id: SiteCustomization::HelpText.find_by(section: "polls").id,
            title: "Ajuda Votacions",
            content: "Contingut d'Ajuda Votacions",
            locale: "val" },
          { site_customization_help_text_id: SiteCustomization::HelpText.find_by(section: "processes").id,
            title: "Ajuda Elaboració normativa",
            content: "Contingut d'Ajuda Elaboració normativa",
            locale: "val" },
          { site_customization_help_text_id: SiteCustomization::HelpText.find_by(section: "budgets").id,
            title: "Ajuda pressupostos participatius",
            content: "Contingut d'Ajuda pressupostos participatius",
            locale: "val" }
        ].each do |attrs|
          SiteCustomization::HelpText::Translation.find_or_create_by!(attrs)
        end
      end
    end
  end
end
