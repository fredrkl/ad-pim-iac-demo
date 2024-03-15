# AD PIM IaC Demo

This repository contains demo IaC (Infrastructure as Code) for Azure AD Privileged Identity Management.

## Requirements

- Microsoft Entra Identity Protection Plan 2 (P2)

## PIM for Azure Resources

PIM for Azure Resources is a service in Azure that enables you to manage, control, and monitor just-in-time Azure resources access within your organization.

## Lessons Learned

- The [terraform documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/pim_eligible_role_assignment#schedule) states the `ExpirationRule` is optional. However, not setting it results in the error:

```
Unexpected status 400 with error: RoleAssignmentRequestPolicyValidationFailed: The following policy rules failed: ["ExpirationRule"]
```

- It is not possible to set the PIM role assignment expiration duration to not expire.
