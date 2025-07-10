module ApplicationHelper
  def currency_format(amount)
    number_to_currency(amount, precision: 0)
  end

  def percentage_format(percentage)
    number_to_percentage(percentage, precision: 1)
  end

  def utilization_progress_bar(category)
    percentage = category.utilization_percent
    color_class = case category.utilization_status
                  when 'low' then 'bg-success'
                  when 'medium' then 'bg-info'
                  when 'high' then 'bg-warning'
                  when 'critical' then 'bg-danger'
                  when 'over_limit' then 'bg-danger'
                  else 'bg-secondary'
                  end

    content_tag :div, class: 'progress' do
      content_tag :div, '', 
                  class: "progress-bar #{color_class}",
                  style: "width: #{[percentage, 100].min}%",
                  'aria-valuenow': percentage,
                  'aria-valuemin': 0,
                  'aria-valuemax': 100,
                  title: "#{percentage}% utilized"
    end
  end

  def impact_badge(impact_metric)
    return content_tag(:span, 'No Assessment', class: 'badge bg-secondary') unless impact_metric

    score = impact_metric.overall_impact_score
    color = case score
            when 0...3 then 'danger'
            when 3...6 then 'warning'
            when 6...8 then 'success'
            when 8..10 then 'primary'
            end

    content_tag :span, impact_metric.impact_category, 
                class: "badge bg-#{color}"
  end

  def sustainability_badge(score)
    return content_tag(:span, 'N/A', class: 'badge bg-secondary') unless score

    color = case score
            when 1..3 then 'danger'
            when 4..6 then 'warning'
            when 7..8 then 'success'
            when 9..10 then 'primary'
            end

    level = case score
            when 1..3 then 'Low'
            when 4..6 then 'Medium'
            when 7..8 then 'High'
            when 9..10 then 'Very High'
            end

    content_tag :span, "#{level} (#{score}/10)", 
                class: "badge bg-#{color}"
  end

  def phase_status_badge(phase)
    case phase.status
    when 'active'
      content_tag :span, 'Active', class: 'badge bg-success'
    when 'upcoming'
      content_tag :span, 'Upcoming', class: 'badge bg-info'
    when 'completed'
      content_tag :span, 'Completed', class: 'badge bg-secondary'
    else
      content_tag :span, 'Inactive', class: 'badge bg-light text-dark'
    end
  end

  def project_status_badge(project)
    case project.status
    when 'pending'
      content_tag :span, 'Pending', class: 'badge bg-warning'
    when 'approved'
      content_tag :span, 'Approved', class: 'badge bg-success'
    when 'rejected'
      content_tag :span, 'Rejected', class: 'badge bg-danger'
    when 'implemented'
      content_tag :span, 'Implemented', class: 'badge bg-primary'
    end
  end

  def votes_remaining_text(user, budget)
    remaining = user.votes_remaining_for_budget(budget)
    pluralize(remaining, 'vote') + ' remaining'
  end

  def format_timeline(timeline)
    timeline.presence || 'Not specified'
  end

  def category_limit_warning(category)
    return unless category.near_limit?

    content_tag :div, class: 'alert alert-warning alert-sm' do
      icon('exclamation-triangle') + 
      " Category is at #{category.utilization_percent}% of spending limit"
    end
  end

  def can_vote_indicator(project, user)
    if user&.can_vote_for_project?(project)
      content_tag :span, '✓ Can vote', class: 'text-success small'
    elsif user&.voted_for_project?(project)
      content_tag :span, '✓ Voted', class: 'text-primary small'
    elsif user
      content_tag :span, '✗ Cannot vote', class: 'text-muted small'
    else
      content_tag :span, 'Login to vote', class: 'text-info small'
    end
  end

  private

  def icon(name)
    # Simple icon helper - replace with your preferred icon library
    content_tag :i, '', class: "fas fa-#{name}"
  end
end 