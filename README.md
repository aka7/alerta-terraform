# Setting up single instance alerta for quick demo testing on aws

In my example, we are going to setup and launch one AWS EC2 instance which configures alerta. Please read the Pre-requisites below and make sure you are happy to proceed.

This example demostrates use of terrform, providing details withuserdata, recodring the instance details in consul and finally doing a puppet run to configure alerta.

The end of the run, you should able get to http://<EC2_PUBLIC_DNS>

---
## Pre-Requisites:

1. Install Terraform. [link](https://www.terraform.io/intro/getting-started/install.html)
2. Have an account on AWS (free Tier if possible). [link](https://aws.amazon.com/free)
3. Some basic knowledge of AWS.
  * Creating and download your key pair (.pem file). [link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
  * Create your Access key and access secret (one time creation). [link](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
  * Check your default default, this example will use your default vpc.
  * Familiarity with the AWS console.
  * basice knowlege of alerta. [link] (http://alerta.io/)
  * AWS training - I recommend Ryan Kroonemburg on Udemy. [link](https://www.udemy.com/user/ryankroonenburg/)

## Now on your server (where you have installed Terraform)

Setup your credentails for using aws
  * set the credential sources. one way is to set it in .aws/credentials file

```
cat ~/.aws/credentials
[default]
aws_access_key_id = 
aws_secret_access_key =
```
I find it easier to keep this seperate so I dont commit the keys in git.


Take a copy of my git repo. It contains all the files you need for this example.

```
$ git clone https://github.com/aka7/alerta-terraform.git 
$ cd alerta-terraform
$ terraform init 
```

Make the following changes to these files in the code you have cloned from me in Git:

Set the ssh keypair name in varibales.tf

```
variable "ssh_key_name" { default = "YOUR_KEYPAIR_NAME" }

```

If you need to set region, amis etc, in variables.tf, or use default, eu-west-1.  

NOTE: if you change ami id, make sure its ubuntu ami for this example to work.

Run plan and apply when ready
```
$ terraform  plan
$ terraform apply
```

alerta should be ready to be tested at http://public_dns/

