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

 # $expirationRule = @{
 #             isExpirationRequired = "false";
 #             maximumDuration = "P180D";
 #             id = "Expiration_Admin_Eligibility";
 #             ruleType = [RoleManagementPolicyRuleType]("RoleManagementPolicyExpirationRule");
 #             targetCaller = "Admin";
 #             targetOperation = @('All');
 #             targetLevel = "Eligibility";
 #             targetObject = $null;
 #             targetInheritableSetting = $null;
 #             targetEnforcedSetting = $null;
 #         }
  $expirationRule = @{
    isExpirationRequired     = "false";
    maximumDuration          = "P365D";
    id                       = "Expiration_Admin_Eligibility";
    ruleType                 = "RoleManagementPolicyExpirationRule";
    targetCaller             = "Admin";
    targetOperation          = @('All');
    targetLevel              = "Eligibility";
    targetObject             = $null;
    targetInheritableSetting = $null;
    targetEnforcedSetting    = $null;
  }
  $rules = @($expirationRule)
  Update-AzRoleManagementPolicy -Scope $Scope -Name $Policy.Name -Rule $rules

  #$Policy = Get-AzRoleManagementPolicy -Scope $Scope | Where-Object Id -eq $PolicyId

  #$expirationRule = @{
  #  isExpirationRequired     = "false";
  #  maximumDuration          = "P365D";
  #  id                       = "Expiration_Admin_Eligibility";
  #  ruleType                 = "RoleManagementPolicyExpirationRule";
  #  targetCaller             = "Admin";
  #  targetOperation          = @('All');
  #  targetLevel              = "Eligibility";
  #  targetObject             = $null;
  #  targetInheritableSetting = $null;
  #  targetEnforcedSetting    = $null;
  #}
  #
  #@pimRule = @{
  #  ruleType = "RoleManagementPolicyPimRule";
  #  id = "PIM_Admin_Eligibility";
  #  targetCaller = "Admin";
  #  targetOperation = @('All');
  #  targetLevel = "Eligibility";
  #  targetObject = $null;
  #  targetInheritableSetting = $null;
  #  targetEnforcedSetting = $null;
  #  targetPimSetting = @{
  #    isPimRequired = "true";
  #    pimType = "PIM";
  #    pimRole = "Owner";
  #    pimDuration = "P7D";
  #  }
  #}
  #
  #$rules = @($expirationRule)
  #Update-AzRoleManagementPolicy -Scope $scope -Name $Policy.Name -Rule $rules
}

listPolicyAssignments -Scope "/subscriptions/57cd39e7-07f1-4555-adea-802d4fc5a5e1" -Role "Owner"
