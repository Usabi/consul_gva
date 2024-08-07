module MilestonesHelper
  def progress_tag_for(progress_bar)
    text = number_to_percentage(progress_bar.percentage, precision: 0)

    tag.div class: "progress",
            role: "progressbar",
            "aria-valuenow": progress_bar.percentage,
            "aria-valuetext": "#{progress_bar.percentage}%",
            "aria-valuemax": ProgressBar::RANGE.max,
            "aria-valuemin": "0",
            tabindex: "0" do
      tag.span(class: "progress-meter", style: "width: #{progress_bar.percentage}%;") +
        tag.p(text, class: "progress-meter-text")
    end
  end

  def milestone_status_percentage(status_kind)
    percentage = {
      drafting: 25,
      processing: 50,
      execution: 75,
      executed: 100
    }
    percentage[status_kind.to_sym]
  end
end
