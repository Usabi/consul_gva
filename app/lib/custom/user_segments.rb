load Rails.root.join("app", "lib", "user_segments.rb")

class UserSegments
  def self.segments
    %w[all_users
       administrators
       legislators
       all_organizations
       pending_organizations
       verified_organizations
       rejected_organizations
       all_proposal_authors
       proposal_authors
       investment_authors
       feasible_and_undecided_investment_authors
       selected_investment_authors
       winner_investment_authors
       not_supported_on_current_budget
       newsletter_debates
       newsletter_proposals
       newsletter_legislation] + geozones.keys
  end

  def self.legislators
    all_users.legislators
  end

  def self.all_organizations
    author_ids(Organization.pluck(:user_id))
  end

  def self.pending_organizations
    author_ids(Organization.pending.pluck(:user_id))
  end

  def self.verified_organizations
    author_ids(Organization.verified.pluck(:user_id))
  end

  def self.rejected_organizations
    author_ids(Organization.rejected.pluck(:user_id))
  end

  def self.newsletter_debates
    all_users.newsletter_debates_subscribers
  end

  def self.newsletter_proposals
    all_users.newsletter_proposals_subscribers
  end

  def self.newsletter_legislation
    all_users.newsletter_legislation_subscribers
  end

  def self.recipients(segment)
    segments = Array(segment)

    matching_users = segments.flat_map do |seg|
      if geozones[seg.to_s]
        all_users.where(geozone: geozones[seg.to_s])
      elsif valid_segment?(seg)
        send(seg)
      else
        User.none
      end
    end

    all_users.where(id: matching_users.map(&:id).uniq)
  end
end
