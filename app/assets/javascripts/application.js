//= require_tree .

// Simple JavaScript for the application
document.addEventListener('DOMContentLoaded', function() {
  console.log('Application loaded');
  
  // Add any custom JavaScript here
  // For example, Bootstrap tooltips
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  });
}); 