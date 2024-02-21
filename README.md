VPC Connection Demo
===================

This demonstrates the connection options for initiating a private, secure connection into a VPC from a remote location.

Steps:
1. Run `terraform apply` to create all the AWS resources.
2. Install [AWS Session Manager Plugin for AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

This will create the following infrastructure:

1. A VPC with a public and private subnet.
2. A Postgres RDS instance in the private subnet.
3. An EC2 instance in the private subnet.
4. An AppStream instance in the private subnet.

Note that NO resources are placed in the private subnet. Thus, nothing here is internet-accessible!

### Using the AppStream instance:

1. Go to the AppStream console: https://us-east-1.console.aws.amazon.com/appstream2/home?region=us-east-1#/fleets
2. Click "User Pool", and add a user. 
3. Associate that user with a stack. 
4. Check your email for temporary credentials and use them to log in.
5. Once logged in, you can use the AppStream instance.
6. You can see that the Postgres hostname is resolved, but the connection is refused.

### Using the Jump instance:

```shell
# SSH into the jump instance
./bin/jump.sh
# Once inside the jump instance, install Postgres and connect.
dnf install postgresql15
# Note: you will need to update the hostname here.
psql -h demo.cyaccbockaim.us-east-1.rds.amazonaws.com -U demo postgres
```

Pros:
* Direct IAM authentication.
* Sessions can be logged and audited.

Cons:
* No copy/paste protection.
* Can also be used to tunnel a connection, which would 