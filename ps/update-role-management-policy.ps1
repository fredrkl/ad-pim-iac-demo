function listPolicyAssignments {
  param (
    [Parameter(Mandatory = $True)]
    [string]$Scope,
    [Parameter(Mandatory = $True)]
    [string]$Role
  )
  
  $ErrorActionPreference = "Stop"
  
  Write-Host "Scope is [$Scope]"
  Write-Host "Role is [$Role]"

  # Get the policy assignment
  $PolicyId = Get-AzRoleManagementPolicyAssignment -Scope $Scope | Where-Object RoleDefinitionDisplayName -EQ $Role | ForEach-Object PolicyId
  Write-Host "PolicyId is [$PolicyId] for Role [$Role]"

  # Get the policy itself
  $Policy = Get-AzRoleManagementPolicy -Scope $Scope | Where-Object Id -eq $PolicyId

  # Need to have the full namespace for the ruleType: https://github.com/Azure/azure-powershell/issues/18781
  $pimRule = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyApprovalRule]@{
    id                        = "Approval_EndUser_Assignment";
    ruleType                  = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Support.RoleManagementPolicyRuleType]("RoleManagementPolicyApprovalRule");
    settingApprovalMode       = $null;
    settingApprovalStage      = @(
      @{
          escalationTimeInMinute = 0;
          isApproverJustificationRequired = "true";
          isEscalationEnabled = "false";
          primaryApprover = @(
            @{
              description = "securityManagers";
              id = "03807c38-aa7e-479b-87c1-7ef86265691e";
              isBackup = "false";
              userType = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Support.UserType]("Group");
            }
          );
          timeOutInDay = 1;
        }
    );
    settingIsApprovalRequired = "true";
    settingIsApprovalRequiredForExtension = "false";
    settingIsRequestorJustificationRequired = "true";
    target =
      @{
        caller = "EndUser";
        enforcedSetting = $null;
        inheritableSetting = $null;
        level = "Assignment";
        operation = @('All');
      };
    targetCaller               = "EndUser";
    targetEnforcedSetting      = $null;
    targetInheritableSetting   = $null;
    targetLevel                = "Assignment";
    targetObject               = $null;
    targetOperation            = @('All');
  }
  
  # Require dual approval for role assignments
  $dualPim = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyExpirationRule]@{
    id                       = "Expiration_EndUser_Assignment";
    ruleType                  = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Support.RoleManagementPolicyRuleType]("RoleManagementPolicyExpirationRule");
    isExpirationRequired     = "false";
    maximumDuration          = "PT3H";
    targetCaller             = "EndUser";
    targetOperation          = @('All');
    targetLevel              = "Assignment";
    targetObject             = $null;
    targetInheritableSetting = $null;
    targetEnforcedSetting    = $null;
  }

  # Make non-expiring eligibility possible
  $expirationRule = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyExpirationRule]@{
    id                       = "Expiration_Admin_Eligibility";
    ruleType                  = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Support.RoleManagementPolicyRuleType]("RoleManagementPolicyExpirationRule");
    isExpirationRequired     = "false";
    maximumDuration          = "P365D";
    targetCaller             = "Admin";
    targetOperation          = @('All');
    targetLevel              = "Eligibility";
    targetObject             = $null;
    targetInheritableSetting = $null;
    targetEnforcedSetting    = $null;
  }

  $rules = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.IRoleManagementPolicyRule[]]@($pimRule, $expirationRule, $dualPim)
  Update-AzRoleManagementPolicy -Scope $Scope -Name $Policy.Name -Rule $rules -Debug
}

listPolicyAssignments -Scope "/subscriptions/57cd39e7-07f1-4555-adea-802d4fc5a5e1" -Role "Owner"
