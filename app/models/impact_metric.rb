class ImpactMetric < ApplicationRecord
  belongs_to :budget_project

  validates :estimated_beneficiaries, presence: true, 
            numericality: { greater_than_or_equal_to: 0 }
  validates :sustainability_score, presence: true, 
            numericality: { in: 1..10 }
  validates :timeline, presence: true

  before_save :calculate_cost_per_beneficiary

  # Enhancement 3: Impact assessment methods
  def self.timeline_options
    [
      ['1-3 months', '1-3 months'],
      ['3-6 months', '3-6 months'],
      ['6-12 months', '6-12 months'],
      ['1-2 years', '1-2 years'],
      ['2+ years', '2+ years'],
      ['Ongoing', 'ongoing']
    ]
  end

  def sustainability_level
    case sustainability_score
    when 1..3
      'Low'
    when 4..6
      'Medium'
    when 7..8
      'High'
    when 9..10
      'Very High'
    end
  end

  def sustainability_color
    case sustainability_score
    when 1..3
      'danger'
    when 4..6
      'warning'
    when 7..8
      'success'
    when 9..10
      'primary'
    end
  end

  def overall_impact_score
    # Weighted score combining beneficiaries, sustainability, and cost-effectiveness
    beneficiary_score = [estimated_beneficiaries / 100.0, 10.0].min
    cost_effectiveness_score = cost_per_beneficiary.present? && cost_per_beneficiary > 0 ? 
                              [1000.0 / cost_per_beneficiary, 10.0].min : 0
    
    (beneficiary_score * 0.4 + sustainability_score * 0.4 + cost_effectiveness_score * 0.2).round(2)
  end

  def impact_category
    case overall_impact_score
    when 0...3
      'Low Impact'
    when 3...6
      'Medium Impact'
    when 6...8
      'High Impact'
    when 8..10
      'Very High Impact'
    end
  end

  def impact_summary
    summary = []
    summary << "#{estimated_beneficiaries} estimated beneficiaries"
    summary << "#{sustainability_level.downcase} sustainability"
    summary << "#{timeline} timeline"
    summary << "$#{cost_per_beneficiary&.round(2)}/beneficiary" if cost_per_beneficiary.present?
    summary.join(', ')
  end

  def has_environmental_impact?
    environmental_impact.present?
  end

  def has_social_impact?
    social_impact.present?
  end

  def has_economic_impact?
    economic_impact.present?
  end

  def impact_types
    types = []
    types << 'Environmental' if has_environmental_impact?
    types << 'Social' if has_social_impact?
    types << 'Economic' if has_economic_impact?
    types
  end

  private

  def calculate_cost_per_beneficiary
    return unless budget_project&.requested_amount && estimated_beneficiaries > 0
    
    self.cost_per_beneficiary = budget_project.requested_amount / estimated_beneficiaries
  end
end 