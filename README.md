# awesome-challenge

This project was created to solve a challenge where several machines are deployed in multi availability zones in a region of AWS.

The following features will be deployed:

- Create Ec2 Instances under a load balancer.
- Launch Ec2 Instances with a role with s3 access already attached.
- Launch Ec2 instances in the private VPC, and also install Apache server, use bootstrapping.
- Create an autoscaling group with a minimum size of 1 and a maximum size of 3 with the previously load balancer already created.
  - Write a life cycle policy with the following parameters.
    - scale in: CPU Utilization > 80%
    - scale out: CPU Utilization < 60%

## Usage
In case you need deploy the whole solution, you should run the following commands.

> The terraform init command is used to initialize a working directory containing Terraform configuration files.

```bash
    terraform init
```

> The terraform get command is used to download and update modules mentioned in the root module.

```bash
    terraform get 
```

>The terraform plan command is used to create an execution plan.

```bash
    terraform plan
```

> The terraform apply command is used to apply the changes required to reach the desired state of the configuration.

```bash
    terraform apply
```

> The terraform destroy command is used to destroy the Terraform-managed infrastructure.
```bash
    terraform destroy
```

# Securtity improvements

The current deployed ec2 machines have a System manager agent to improve security connections, this way open an ssh port is not necessary.

Steps:

    - Go to System manager service.
    - Enter to Session Manager.
    - Start a new session.
    - Once the infrastructure is deployed you should watch the machines there, you can select one and connect via SSM agent.

# Built With

* [terraform](https://www.terraform.io/) - Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services.

## Authors

- Hugo Lesta - <hlesta@icloud.com>