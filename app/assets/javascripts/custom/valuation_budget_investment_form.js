(function() {
  "use strict";
  App.ValuationBudgetInvestmentForm = {
    showFeasibleFields: function() {
      $("#valuation_budget_investment_edit_form #unfeasible_fields").hide("down");
      $("#valuation_budget_investment_edit_form #feasible_fields").show();
      $("#valuation_budget_investment_edit_form #not_selected_fields").hide("down");
      $("#valuation_budget_investment_edit_form #next_year_budget_fields").hide("down");
      $("#valuation_budget_investment_edit_form #takecharge_fields").hide("down");
    },
    showNotFeasibleFields: function() {
      $("#valuation_budget_investment_edit_form #feasible_fields").hide("down");
      $("#valuation_budget_investment_edit_form #unfeasible_fields").show();
      $("#valuation_budget_investment_edit_form #not_selected_fields").hide("down");
      $("#valuation_budget_investment_edit_form #next_year_budget_fields").hide("down");
      $("#valuation_budget_investment_edit_form #takecharge_fields").hide("down");
    },
    showNotSelectedFields: function() {
      $("#valuation_budget_investment_edit_form #feasible_fields").hide("down");
      $("#valuation_budget_investment_edit_form #unfeasible_fields").hide();
      $("#valuation_budget_investment_edit_form #not_selected_fields").show("down");
      $("#valuation_budget_investment_edit_form #next_year_budget_fields").hide("down");
      $("#valuation_budget_investment_edit_form #takecharge_fields").hide("down");
    },
    showTakechargeFields: function() {
      $("#valuation_budget_investment_edit_form #feasible_fields").hide("down");
      $("#valuation_budget_investment_edit_form #unfeasible_fields").hide("down");
      $("#valuation_budget_investment_edit_form #not_selected_fields").hide("down");
      $("#valuation_budget_investment_edit_form #takecharge_fields").show("down");
      $("#valuation_budget_investment_edit_form #next_year_budget_fields").hide("down");
    },
    showNextYearBudgetFields: function() {
      $("#valuation_budget_investment_edit_form #feasible_fields").hide("down");
      $("#valuation_budget_investment_edit_form #unfeasible_fields").hide("down");
      $("#valuation_budget_investment_edit_form #not_selected_fields").hide("down");
      $("#valuation_budget_investment_edit_form #takecharge_fields").hide("down");
      $("#valuation_budget_investment_edit_form #next_year_budget_fields").show("down");
    },
    showAllFields: function() {
      $("#valuation_budget_investment_edit_form #feasible_fields").show("down");
      $("#valuation_budget_investment_edit_form #unfeasible_fields").show("down");
      $("#valuation_budget_investment_edit_form #not_selected_fields").show("down");
      $("#valuation_budget_investment_edit_form #next_year_budget_fields").hide("down");
      $("#valuation_budget_investment_edit_form #takecharge_fields").hide("down");
    },
    showFeasibilityFields: function() {
      var feasibility;
      feasibility = $("#valuation_budget_investment_edit_form input[type=radio][name='budget_investment[feasibility]']:checked").val();
      if (feasibility === "feasible") {
        App.ValuationBudgetInvestmentForm.showFeasibleFields();
      } else if (feasibility === "unfeasible") {
        App.ValuationBudgetInvestmentForm.showNotFeasibleFields();
      } else if (feasibility === "not_selected") {
        App.ValuationBudgetInvestmentForm.showNotSelectedFields();
      } else if (feasibility === "takecharge") {
        App.ValuationBudgetInvestmentForm.showTakechargeFields();
      } else if (feasibility === "nextyearbudget") {
        App.ValuationBudgetInvestmentForm.showNextYearBudgetFields();
      }
    },
    showFeasibilityFieldsOnChange: function() {
      $("#valuation_budget_investment_edit_form input[type=radio][name='budget_investment[feasibility]']").on("change", function() {
        App.ValuationBudgetInvestmentForm.showAllFields();
        App.ValuationBudgetInvestmentForm.showFeasibilityFields();
      });
    },
    initialize: function() {
      App.ValuationBudgetInvestmentForm.showFeasibilityFields();
      App.ValuationBudgetInvestmentForm.showFeasibilityFieldsOnChange();
    }
  };
}).call(this);
