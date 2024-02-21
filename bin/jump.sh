#!/usr/bin/env bash

JUMP_INSTANCE=$(aws ec2 describe-instances --filters Name=tag:Name,Values=jump Name=instance-state-name,Values=running --query "Reservations[0].Instances[0].InstanceId" --output text)

aws ssm start-session \
    --target $JUMP_INSTANCE