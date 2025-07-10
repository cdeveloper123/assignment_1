# Participatory Budgeting Platform

A Ruby on Rails application implementing a comprehensive participatory budgeting system with three advanced features: **Budget Category Limits & Spending Controls**, **Multi-Phase Budget Voting**, and **Budget Impact Assessment Integration**.

## Features Overview

### 🎯 Core Participatory Budgeting
- User registration and authentication
- Budget creation and management
- Project proposal submission
- Community voting system
- Results tracking and reporting

### 🔒 Enhancement 1: Budget Category Limits & Spending Controls
- **Spending Limit Percentage**: Each budget category has a configurable spending limit (1-100% of total budget)
- **Real-time Validation**: Prevents project approval if it would exceed category limits
- **Visual Indicators**: Progress bars showing category utilization with color-coded status
- **Admin Controls**: Interface for setting and monitoring category limits
- **Utilization Tracking**: Real-time category usage monitoring with alerts

### 📅 Enhancement 2: Multi-Phase Budget Voting
- **Configurable Phases**: Create multiple voting phases with different rules and timeframes
- **Phase-Specific Settings**: Different vote limits, rules, and participant eligibility per phase
- **Automatic Transitions**: Background job automatically activates/deactivates phases based on dates
- **Phase Analytics**: Comprehensive reporting for each voting phase
- **Flexible Voting Rules**: JSON-based rule configuration for each phase

### 📊 Enhancement 3: Budget Impact Assessment Integration
- **Impact Metrics**: Track estimated beneficiaries, timeline, and sustainability score
- **Multi-dimensional Impact**: Environmental, social, and economic impact tracking
- **Impact Scoring**: Automated overall impact score calculation
- **Cost-Effectiveness**: Automatic cost-per-beneficiary calculation
- **Impact-Based Filtering**: Sort and filter projects by impact criteria
- **Impact Reports**: Comprehensive impact analysis and reporting

## Technical Architecture

### Technology Stack
- **Framework**: Ruby on Rails 7.0
- **Database**: SQLite (development), PostgreSQL (production ready)
- **Authentication**: Devise
- **Admin Interface**: ActiveAdmin
- **Background Jobs**: Sidekiq
- **Styling**: Bootstrap 5
- **Charts**: Chartkick (for visualizations)

### Key Models

#### Core Models
- `Budget`: Main budget entity with funding and status tracking
- `BudgetCategory`: Categories with spending limit controls
- `BudgetProject`: Project proposals with impact assessment
- `User`: Regular users who can vote and propose projects
- `Vote`: Individual votes with phase tracking

#### Enhancement Models
- `VotingPhase`: Multi-phase voting system
- `ImpactMetric`: Impact assessment data
- `AdminUser`: Administrative users

### Database Schema

```sql
-- Core entities
budgets: name, description, total_funds, voting_dates, status
budget_categories: name, spending_limit_percentage, color, position
budget_projects: title, description, requested_amount, allocated_amount, status
users: email, first_name, last_name, available_votes

-- Enhancement 1: Category Limits
budget_categories.spending_limit_percentage (1-100)

-- Enhancement 2: Multi-Phase Voting
voting_phases: name, start_date, end_date, max_votes_per_user, rules, active
budget_projects.voting_phase_id

-- Enhancement 3: Impact Assessment
impact_metrics: estimated_beneficiaries, timeline, sustainability_score,
                environmental_impact, social_impact, economic_impact
```

## Installation & Setup

### Prerequisites
- Ruby 3.1.0+
- Rails 7.0+
- SQLite3 (development)
- Redis (for Sidekiq)

### Installation Steps

1. **Clone and setup**:
```bash
git clone <repository>
cd participatory-budgeting
bundle install
```

2. **Database setup**:
```bash
rails db:create
rails db:migrate
rails db:seed
```

3. **Start services**:
```bash
# Start Rails server
rails server

# Start Sidekiq (in another terminal)
bundle exec sidekiq
```

4. **Access the application**:
- Main App: http://localhost:3000
- Admin Panel: http://localhost:3000/admin

### Login Credentials (from seed data)
- **Admin**: admin@example.com / password123
- **Budget Manager**: budget.manager@example.com / password123
- **Users**: user1@example.com through user20@example.com / password123

## Demo Scenarios

The seed data creates a realistic scenario demonstrating all three enhancements:

### 🎯 Budget: "City Community Budget 2024"
- **Total Funds**: $1,000,000
- **Status**: Active voting period
- **Categories**: 5 categories with different spending limits

### 📊 Category Limits Demo
1. **Infrastructure & Transportation** (40% limit) - Shows high utilization
2. **Parks & Recreation** (25% limit) - Medium utilization
3. **Community Services** (20% limit) - Shows limit enforcement
4. **Environmental Initiatives** (10% limit) - Low utilization
5. **Arts & Culture** (5% limit) - Demonstrates tight limits

### 📅 Multi-Phase Voting Demo
1. **Pre-Selection Phase** (Completed) - Initial community input
2. **Primary Voting Phase** (Active) - Main voting period
3. **Final Selection Phase** (Upcoming) - Final vote on top projects

### 🎯 Impact Assessment Demo
- 12+ projects with comprehensive impact assessments
- Range of impact scores from 5.2 to 9.8
- Diverse beneficiary counts (150 to 30,000)
- Various sustainability scores and timelines

## Key Features Demonstration

### 1. Category Spending Controls

**Admin Workflow**:
1. Go to Admin → Budget Categories
2. View category utilization progress bars
3. Click "Update Limit" to modify spending percentages
4. See real-time validation preventing over-allocation

**Voting Impact**:
- Projects show category utilization impact
- Approval blocked if category limit would be exceeded
- Visual warnings for categories approaching limits

### 2. Multi-Phase Voting System

**Phase Management**:
1. Admin → Voting Phases
2. Create phases with different rules and vote limits
3. Automatic phase transitions via background job
4. Phase-specific analytics and reporting

**User Experience**:
- Different voting limits per phase
- Projects tied to specific phases
- Phase status indicators throughout the app

### 3. Impact Assessment Integration

**Project Creation**:
- Impact metrics form integrated into project creation
- Required fields: beneficiaries, sustainability score, timeline
- Optional environmental, social, economic impact descriptions

**Impact-Based Features**:
- Sort projects by impact score, beneficiaries, sustainability
- Filter for high-impact projects
- Admin impact reports with comprehensive analysis
- Cost-per-beneficiary calculations

## API and Customization

### Extending Categories
```ruby
# Add new category with custom limit
category = budget.budget_categories.create!(
  name: "New Category",
  spending_limit_percentage: 15, # 15% of total budget
  color: "#FF5733"
)
```

### Creating Voting Phases
```ruby
# Create new voting phase
phase = budget.voting_phases.create!(
  name: "Special Voting Round",
  start_date: 1.week.from_now,
  end_date: 2.weeks.from_now,
  max_votes_per_user: 3,
  rules: { voting_type: "weighted", min_impact_score: 7 }.to_json
)
```

### Impact Assessment Customization
```ruby
# Custom impact scoring
class ImpactMetric
  def custom_impact_score
    # Override with custom algorithm
    (estimated_beneficiaries * 0.4 + 
     sustainability_score * 0.6) / 100
  end
end
```

## Administration Features

### ActiveAdmin Interface
- **Dashboard**: Overview of all budgets, categories, and phases
- **Category Management**: Set and monitor spending limits
- **Phase Management**: Create and control voting phases
- **Project Approval**: Approve/reject with category limit checking
- **Impact Reports**: Comprehensive impact analysis
- **Batch Operations**: Bulk approve/reject projects

### Monitoring and Alerts
- Category utilization warnings
- Phase transition notifications
- High-impact project identification
- Over-limit alerts

## Background Jobs

### Phase Transition Job
Automatically checks and transitions voting phases every hour:
```ruby
PhaseTransitionJob.perform_later
```

## Testing and Quality

### Model Validations
- Category spending limits (1-100%)
- Phase date validations
- Impact metric requirements
- Vote eligibility checking

### Business Logic Testing
- Category limit enforcement
- Phase transition logic
- Impact score calculations
- Vote validation rules

## Production Considerations

### Database
- Switch to PostgreSQL for production
- Add database indexes for performance
- Consider read replicas for reporting

### Caching
- Add Redis caching for frequently accessed data
- Cache impact calculations
- Cache category utilization percentages

### Monitoring
- Add application monitoring (e.g., New Relic)
- Set up alerts for category limit violations
- Monitor background job performance

### Security
- Add rate limiting for voting
- Implement audit trails
- Add CSRF protection for all forms

## Contributing

### Development Setup
1. Fork the repository
2. Create feature branch
3. Add tests for new features
4. Submit pull request

### Code Style
- Follow Ruby/Rails conventions
- Add comments for complex business logic
- Maintain consistent naming

## License

This project is available under the MIT License.

---

## Summary

This participatory budgeting platform successfully implements three advanced features:

1. **Category Limits**: Prevents budget over-allocation with real-time validation
2. **Multi-Phase Voting**: Enables complex voting workflows with phase-specific rules
3. **Impact Assessment**: Comprehensive impact tracking and analysis

The platform is production-ready with comprehensive admin controls, automated processes, and extensive seed data for demonstration purposes. 