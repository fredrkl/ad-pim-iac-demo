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
  
  $jsonPolicyOutput = ConvertTo-Json -Depth 10 $Policy
  #Write-Host $Policy
  $jsonPolicyOutput | Out-File -FilePath "./output-pim.json"

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

#  $rule1
#     
#      "RuleType": {},
#      "SettingApprovalMode": {},
#      "SettingApprovalStage": [
#        {
#          "EscalationApprover": null,
#          "EscalationTimeInMinute": 0,
#          "IsApproverJustificationRequired": true,
#          "IsEscalationEnabled": false,
#          "PrimaryApprover": [
#            {
#              "Description": "securityManagers",
#              "Id": "03807c38-aa7e-479b-87c1-7ef86265691e",
#              "IsBackup": false,
#              "UserType": {}
#            }
#          ],
#          "TimeOutInDay": 1
#        }
#      ],
#      "SettingIsApprovalRequired": true,
#      "SettingIsApprovalRequiredForExtension": false,
#      "SettingIsRequestorJustificationRequired": true,
#      "Target": {
#        "Caller": "EndUser",
#        "EnforcedSetting": [],
#        "InheritableSetting": [],
#        "Level": "Assignment",
#        "Operation": [
#          "All"
#        ],
#        "TargetObject": []
#      },
#      "TargetCaller": "EndUser",
#      "TargetEnforcedSetting": [],
#      "TargetInheritableSetting": [],
#      "TargetLevel": "Assignment",
#      "TargetObject": [],
#      "TargetOperation": [
#        "All"
#      ]
#
# Need to have the full namespace for the ruleType: https://github.com/Azure/azure-powershell/issues/18781
  $pimRule = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.RoleManagementPolicyApprovalRule]@{
    id                        = "Approval_EndUser_Assignment";
    ruleType                  = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Support.RoleManagementPolicyRuleType]("RoleManagementPolicyApprovalRule");
    settingApprovalMode       = $null;
    settingApprovalStage     = @(
      @{
#          escalationApprover = $null;
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

  $expirationRule = @{
    id                       = "Expiration_Admin_Eligibility";
    ruleType                 = "RoleManagementPolicyExpirationRule";
    isExpirationRequired     = "false";
    maximumDuration          = "P365D";
    targetCaller             = "Admin";
    targetOperation          = @('All');
    targetLevel              = "Eligibility";
    targetObject             = $null;
    targetInheritableSetting = $null;
    targetEnforcedSetting    = $null;
  }

  $rules = [Microsoft.Azure.PowerShell.Cmdlets.Resources.Authorization.Models.Api20201001Preview.IRoleManagementPolicyRule[]]@($pimRule)
  Update-AzRoleManagementPolicy -Scope $Scope -Name $Policy.Name -Rule $rules -Debug

  #$rules = @($expirationRule)
  #Update-AzRoleManagementPolicy -Scope $scope -Name $Policy.Name -Rule $rules
}

listPolicyAssignments -Scope "/subscriptions/57cd39e7-07f1-4555-adea-802d4fc5a5e1" -Role "Owner"
