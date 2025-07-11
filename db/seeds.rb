# Clear existing data in development
if Rails.env.development?
  puts "Clearing existing data..."
  Vote.destroy_all
  ImpactMetric.destroy_all
  BudgetProject.destroy_all
  VotingPhase.destroy_all
  BudgetCategory.destroy_all
  Budget.destroy_all
  User.destroy_all
  AdminUser.destroy_all
end

puts "Creating seed data for Participatory Budgeting Platform..."

# Create Admin Users
puts "Creating admin users..."
admin1 = AdminUser.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'System',
  last_name: 'Administrator'
)

admin2 = AdminUser.create!(
  email: 'budget.manager@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Sarah',
  last_name: 'Johnson'
)

# Create regular users
puts "Creating users..."
users = []

20.times do |i|
  user = User.create!(
    email: "user#{i+1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    available_votes: rand(3..10)
  )
  users << user
end

# Create project creators (subset of users who will create projects)
project_creators = users.sample(8)

puts "Created #{users.count} users"

# Create main budget with realistic parameters
puts "Creating budget..."
budget = Budget.create!(
  name: "City Community Budget 2024",
  description: "Annual community budget allocation for city improvement projects. Citizens can propose and vote on projects that will improve our community.",
  total_funds: 1_000_000.00,
  voting_start_date: 1.week.ago.to_date,
  voting_end_date: 3.weeks.from_now.to_date,
  active: true,
  status: 'voting'
)

# Enhancement 1: Create budget categories with spending limits
puts "Creating budget categories with spending limits..."
categories_data = [
  {
    name: "Infrastructure & Transportation",
    description: "Roads, bridges, public transit, bike lanes, and walkways",
    color: "#FF6B6B",
    spending_limit_percentage: 40, # 40% max of total budget
    position: 1
  },
  {
    name: "Parks & Recreation",
    description: "Parks, playgrounds, sports facilities, and recreational programs",
    color: "#4ECDC4",
    spending_limit_percentage: 25, # 25% max of total budget
    position: 2
  },
  {
    name: "Community Services",
    description: "Libraries, community centers, social programs, and public services",
    color: "#45B7D1",
    spending_limit_percentage: 20, # 20% max of total budget
    position: 3
  },
  {
    name: "Environmental Initiatives",
    description: "Sustainability projects, renewable energy, and environmental protection",
    color: "#96CEB4",
    spending_limit_percentage: 10, # 10% max of total budget
    position: 4
  },
  {
    name: "Arts & Culture",
    description: "Public art, cultural events, and community arts programs",
    color: "#FFEAA7",
    spending_limit_percentage: 5, # 5% max of total budget
    position: 5
  }
]

categories = categories_data.map do |cat_data|
  budget.budget_categories.create!(cat_data)
end

puts "Created #{categories.count} categories with spending limits"

# Enhancement 2: Create multi-phase voting system
puts "Creating voting phases..."
phases_data = [
  {
    name: "Pre-Selection Phase",
    description: "Initial community input and project refinement period",
    start_date: 2.weeks.ago,
    end_date: 1.week.ago,
    max_votes_per_user: 10,
    position: 1,
    active: false,
    rules: {
      voting_type: "preliminary",
      allow_comments: true,
      threshold_for_next_phase: 5
    }.to_json
  },
  {
    name: "Primary Voting Phase",
    description: "Main voting period for refined project proposals",
    start_date: 1.week.ago,
    end_date: 1.week.from_now,
    max_votes_per_user: 5,
    position: 2,
    active: true,
    rules: {
      voting_type: "primary",
      weighted_voting: false,
      impact_scoring_visible: true
    }.to_json
  },
  {
    name: "Final Selection Phase",
    description: "Final vote on top projects from primary phase",
    start_date: 1.week.from_now,
    end_date: 3.weeks.from_now,
    max_votes_per_user: 3,
    position: 3,
    active: false,
    rules: {
      voting_type: "final",
      only_top_projects: true,
      minimum_impact_score: 6
    }.to_json
  }
]

phases = phases_data.map do |phase_data|
  budget.voting_phases.create!(phase_data)
end

primary_phase = phases[1] # The currently active phase
final_phase = phases[2]

puts "Created #{phases.count} voting phases"

# Create diverse budget projects with impact assessments
puts "Creating budget projects with impact assessments..."

projects_data = [
  # Infrastructure projects (40% limit)
  {
    title: "Downtown Bike Lane Network",
    description: "Comprehensive bike lane system connecting downtown to residential areas, including protected lanes and bike parking facilities.",
    requested_amount: 150_000,
    justification: "Reduces traffic congestion, promotes sustainable transportation, and improves air quality.",
    category: categories[0], # Infrastructure
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 5000,
      timeline: "6-12 months",
      sustainability_score: 9,
      environmental_impact: "Reduces carbon emissions by promoting cycling over car use",
      social_impact: "Improves accessibility and promotes healthy transportation options",
      economic_impact: "Reduces transportation costs for residents and supports local bike shops"
    }
  },
  {
    title: "Main Street Pedestrian Bridge",
    description: "Accessible pedestrian bridge over Main Street with ADA compliance and aesthetic lighting.",
    requested_amount: 280_000,
    justification: "Improves safety for pedestrians and connects neighborhoods divided by busy street.",
    category: categories[0], # Infrastructure
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 3000,
      timeline: "1-2 years",
      sustainability_score: 7,
      environmental_impact: "Uses sustainable materials and solar-powered lighting",
      social_impact: "Improves safety and accessibility for elderly and disabled residents",
      economic_impact: "Increases foot traffic to local businesses"
    }
  },
  {
    title: "Smart Traffic Light System",
    description: "Upgrade traffic lights with smart sensors to optimize traffic flow and reduce wait times.",
    requested_amount: 120_000,
    justification: "Reduces traffic congestion and fuel consumption through intelligent traffic management.",
    category: categories[0], # Infrastructure
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 15000,
      timeline: "3-6 months",
      sustainability_score: 8,
      environmental_impact: "Reduces vehicle emissions through optimized traffic flow",
      social_impact: "Improves quality of life by reducing commute times",
      economic_impact: "Saves fuel costs and improves business delivery efficiency"
    }
  },

  # Parks & Recreation projects (25% limit)
  {
    title: "Community Garden Network",
    description: "Establish 5 community gardens throughout the city with shared tools, composting, and educational programs.",
    requested_amount: 80_000,
    justification: "Promotes food security, environmental education, and community building.",
    category: categories[1], # Parks & Recreation
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 2500,
      timeline: "6-12 months",
      sustainability_score: 10,
      environmental_impact: "Promotes organic gardening and reduces food transportation emissions",
      social_impact: "Builds community connections and provides healthy food access",
      economic_impact: "Reduces grocery costs for participating families"
    }
  },
  {
    title: "Adventure Playground Renovation",
    description: "Complete renovation of Central Park playground with modern, inclusive equipment and safety surfaces.",
    requested_amount: 180_000,
    justification: "Provides safe, engaging play space for children of all abilities.",
    category: categories[1], # Parks & Recreation
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 8000,
      timeline: "3-6 months",
      sustainability_score: 6,
      environmental_impact: "Uses recycled materials where possible",
      social_impact: "Provides inclusive play space for children with disabilities",
      economic_impact: "Attracts families to the area, supporting local businesses"
    }
  },

  # Community Services projects (20% limit)
  {
    title: "Mobile Library Service",
    description: "Purchase and outfit a mobile library van to serve underserved neighborhoods and seniors.",
    requested_amount: 95_000,
    justification: "Brings library services directly to residents who cannot easily access the main library.",
    category: categories[2], # Community Services
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 1200,
      timeline: "3-6 months",
      sustainability_score: 8,
      environmental_impact: "Reduces individual transportation needs for library access",
      social_impact: "Improves educational access for seniors and mobility-limited residents",
      economic_impact: "Provides job opportunities and supports literacy"
    }
  },
  {
    title: "Youth Coding Academy",
    description: "After-school coding program for teens with equipment, instructors, and certification opportunities.",
    requested_amount: 65_000,
    justification: "Prepares young people for technology careers and reduces digital divide.",
    category: categories[2], # Community Services
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 150,
      timeline: "ongoing",
      sustainability_score: 9,
      environmental_impact: "Promotes digital solutions over paper-based learning",
      social_impact: "Provides career opportunities for underserved youth",
      economic_impact: "Prepares workforce for high-paying technology jobs"
    }
  },
  {
    title: "Senior Meal Delivery Program",
    description: "Nutritious meal delivery service for homebound seniors with volunteer coordination.",
    requested_amount: 85_000,
    justification: "Addresses food insecurity among elderly residents and provides social connection.",
    category: categories[2], # Community Services
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 400,
      timeline: "ongoing",
      sustainability_score: 7,
      environmental_impact: "Reduces food waste through efficient meal planning",
      social_impact: "Reduces isolation and improves nutrition for seniors",
      economic_impact: "Creates part-time employment opportunities"
    }
  },

  # Environmental projects (10% limit)
  {
    title: "Solar Panel Installation Program",
    description: "Install solar panels on 3 municipal buildings with battery storage systems.",
    requested_amount: 85_000,
    justification: "Reduces municipal energy costs and demonstrates renewable energy commitment.",
    category: categories[3], # Environmental
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 25000,
      timeline: "6-12 months",
      sustainability_score: 10,
      environmental_impact: "Significantly reduces carbon footprint and promotes renewable energy",
      social_impact: "Demonstrates environmental leadership and educates community",
      economic_impact: "Reduces long-term energy costs for city operations"
    }
  },
  {
    title: "Urban Tree Planting Initiative",
    description: "Plant 500 native trees throughout the city with 5-year maintenance plan.",
    requested_amount: 40_000,
    justification: "Improves air quality, reduces urban heat island effect, and enhances beautification.",
    category: categories[3], # Environmental
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 30000,
      timeline: "1-2 years",
      sustainability_score: 9,
      environmental_impact: "Improves air quality and provides carbon sequestration",
      social_impact: "Enhances neighborhood aesthetics and provides shade",
      economic_impact: "Increases property values and reduces cooling costs"
    }
  },

  # Arts & Culture projects (5% limit)
  {
    title: "Community Mural Project",
    description: "Commission local artists to create murals on 8 city buildings celebrating community diversity.",
    requested_amount: 35_000,
    justification: "Celebrates community culture, supports local artists, and reduces graffiti.",
    category: categories[4], # Arts & Culture
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 12000,
      timeline: "3-6 months",
      sustainability_score: 6,
      environmental_impact: "Uses environmentally-friendly paints and materials",
      social_impact: "Celebrates diversity and provides artistic expression opportunities",
      economic_impact: "Supports local artists and attracts cultural tourism"
    }
  },
  {
    title: "Outdoor Concert Series",
    description: "Monthly outdoor concerts in the park during summer months with local musicians.",
    requested_amount: 25_000,
    justification: "Provides free cultural entertainment and supports local music scene.",
    category: categories[4], # Arts & Culture
    phase: primary_phase,
    impact: {
      estimated_beneficiaries: 6000,
      timeline: "3-6 months",
      sustainability_score: 5,
      environmental_impact: "Promotes outdoor activities and community gathering",
      social_impact: "Provides accessible cultural events for all income levels",
      economic_impact: "Supports local musicians and food vendors"
    }
  }
]

# Create projects with their impact metrics
projects = projects_data.map.with_index do |project_data, index|
  creator = project_creators[index % project_creators.length]
  
  project = budget.budget_projects.create!(
    title: project_data[:title],
    description: project_data[:description],
    requested_amount: project_data[:requested_amount],
    justification: project_data[:justification],
    budget_category: project_data[:category],
    voting_phase: project_data[:phase],
    user: creator,
    status: 'pending'
  )

  # Enhancement 3: Create impact metric for each project
  project.create_impact_metric!(project_data[:impact])
  
  project
end

puts "Created #{projects.count} projects with impact assessments"

# Create realistic voting patterns
puts "Creating votes..."
vote_count = 0

# Simulate voting behavior with realistic patterns
users.each do |user|
  # Each user votes for 3-5 projects based on their available votes and preferences
  votes_to_cast = [user.available_votes, rand(3..5)].min
  
  # Users tend to vote for higher impact projects
  available_projects = projects.select { |p| p.can_vote?(user) }
  
  # Sort by impact score and add some randomness
  preferred_projects = available_projects.sort_by { |p| -p.impact_metric&.overall_impact_score.to_f + rand(-1..1) }
  
  preferred_projects.first(votes_to_cast).each do |project|
    vote = project.votes.create!(
      user: user,
      voting_phase: project.voting_phase,
      vote_weight: 1.0,
      comment: ["Great project!", "This will really help our community", "Very needed", "Love this idea", ""].sample
    )
    
    if vote.persisted?
      project.increment!(:votes_count)
      vote_count += 1
    end
  end
end

puts "Created #{vote_count} votes"

# Simulate some approved projects to demonstrate category limits
puts "Approving some projects to demonstrate category limits..."

# Sort projects by votes and approve top ones while respecting category limits
top_projects = projects.sort_by(&:votes_count).reverse

approved_count = 0
top_projects.each do |project|
  if project.can_be_approved? && approved_count < 6
    if project.approve_with_allocation!(project.requested_amount)
      approved_count += 1
      puts "  ✓ Approved: #{project.title} (#{project.budget_category.name}) - #{project.budget_category.utilization_percent.round(1)}% category utilization"
    end
  end
end

puts "Approved #{approved_count} projects"

# Display final statistics
puts "\n" + "="*60
puts "SEED DATA SUMMARY"
puts "="*60

puts "\nSystem Overview:"
puts "- Admin Users: #{AdminUser.count}"
puts "- Regular Users: #{User.count}"
puts "- Budgets: #{Budget.count}"
puts "- Categories: #{BudgetCategory.count}"
puts "- Voting Phases: #{VotingPhase.count}"
puts "- Projects: #{BudgetProject.count}"
puts "- Votes Cast: #{Vote.count}"

puts "\nBudget: #{budget.name}"
puts "- Total Funds: #{ActionController::Base.helpers.number_to_currency(budget.total_funds)}"
puts "- Allocated: #{ActionController::Base.helpers.number_to_currency(budget.total_allocated)}"
puts "- Remaining: #{ActionController::Base.helpers.number_to_currency(budget.remaining_funds)}"
puts "- Utilization: #{budget.utilization_percentage}%"

puts "\n" + "Enhancement 1: Category Spending Limits".upcase
categories.each do |category|
  status_indicator = case category.utilization_status
                    when 'low' then '🟢'
                    when 'medium' then '🟡'
                    when 'high', 'critical' then '🟠'
                    when 'over_limit' then '🔴'
                    else '⚪'
                    end
  
  puts "#{status_indicator} #{category.name}: #{category.utilization_percent.round(1)}% of #{category.spending_limit_percentage}% limit"
end

puts "\n" + "Enhancement 2: Multi-Phase Voting".upcase
phases.each do |phase|
  status_indicator = phase.currently_active? ? '🟢' : (phase.completed? ? '✅' : '⏳')
  puts "#{status_indicator} #{phase.name}: #{phase.votes_cast_count} votes, #{phase.projects_count} projects"
end

puts "\n" + "Enhancement 3: Impact Assessment".upcase
high_impact_projects = projects.select { |p| p.impact_metric&.overall_impact_score.to_f >= 8 }
puts "- High Impact Projects (8+ score): #{high_impact_projects.count}"
puts "- Total Estimated Beneficiaries: #{projects.sum(&:estimated_beneficiaries)}"
puts "- Average Sustainability Score: #{(projects.sum(&:sustainability_score) / projects.count.to_f).round(1)}/10"

puts "\nLogin Credentials:"
puts "- Admin: admin@example.com / password123"
puts "- Budget Manager: budget.manager@example.com / password123"
puts "- Users: user1@example.com through user20@example.com / password123"

puts "\nAccess URLs:"
puts "- Main App: http://localhost:3000"
puts "- Admin Panel: http://localhost:3000/admin"
puts "- Budget Dashboard: http://localhost:3000/budgets/#{budget.id}/admin_dashboard"

puts "\n" + "="*60
puts "Seed data creation completed successfully!"
puts "Ready to demonstrate all three participatory budgeting enhancements!"
puts "="*60 