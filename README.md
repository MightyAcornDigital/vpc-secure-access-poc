Role Escalation Alerts
======================

This demonstrates a technique for generating SNS messages for role escalation events. 

To test:
1. Create a terraform.tfvars file containing a `role_arns` variable that lists the ARNs of some roles you want to receive alerts for.
2. Run `terraform init` and `terraform apply` to create the resources.
3. Subscribe via Email to the created SNS topic in the AWS console.
4. Assume the role through any means (SSO login, regular AssumeRole, etc).
5. You should receive an email alerting you to the role escalation event.
