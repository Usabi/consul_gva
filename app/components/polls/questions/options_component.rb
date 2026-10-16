class Polls::Questions::OptionsComponent < ApplicationComponent
  attr_reader :question
  delegate :can?, :current_user, :user_signed_in?, to: :helpers

  def initialize(question)
    @question = question
  end

  def already_answered?(question_option)
    user_answer(question_option).present?
  end

  def question_options
    question.question_options
  end

  def user_answer(question_option)
    user_answers.find_by(answer: question_option.title)
  end

  def disable_option?(question_option)
    question.multiple? && user_answers.count == question.max_votes
  end

  private

    def user_answers
      @user_answers ||= question.answers.by_author(current_user)
    end
end
