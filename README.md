# Setting up single instance alerta for quick demo on aws, for testing purpose only

In my example, we are going to setup and launch one AWS EC2 instance which configures alerta. Please read the Pre-requisites below and make sure you are happy to proceed.

This example demostrates use of terraform, providing details with userdata, recording the instance details in consul (demo site, demo.consul.io) and finally doing a puppet run to configure alerta.

The end of the run, you should able get to http://<EC2_PUBLIC_DNS>


---
## Pre-Requisites:

1. Install Terraform. [link](https://www.terraform.io/intro/getting-started/install.html)
2. Have an account on AWS (free Tier if possible). [link](https://aws.amazon.com/free)
3. Some basic knowledge of AWS.
  * Creating and download your key pair (.pem file). [link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
  * Create your Access key and access secret (one time creation). [link](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
  * Check your default vpc, this example will use your default vpc.
  * Familiarity with the AWS console and [aws clil](https://aws.amazon.com/cli/)
  * AWS training - I recommend Ryan Kroonemburg on Udemy. [link](https://www.udemy.com/user/ryankroonenburg/)
4. basic knowlege of alerta. [link](http://alerta.io/)

## Now on your host (where you have installed Terraform)

### Step 1 - Setup your credentails for using aws
  * set the credential sources. one way is to set it in .aws/credentials file, shown below.

```
cat ~/.aws/credentials
[default]
aws_access_key_id = 
aws_secret_access_key =
```
It is recommended to keep your keys outside the git repo's so you dont commit the keys into git by mistake.

Or if you have [aws clil](https://aws.amazon.com/cli/)  installed, run configure to set your keys, which will create the file for you.
```
aws configure

```


### Step 2 - Take a copy of my git repo. 
It contains all the files you need for this example.

```
$ git clone https://github.com/aka7/alerta-terraform.git 
$ cd alerta-terraform
$ terraform init 
```

### Step 3  - Make variable changes to suit your environment
Make the following changes to these files in the code you have cloned:

Set the ssh keypair name in varibales.tf

```
variable "ssh_key_name" { default = "YOUR_KEYPAIR_NAME" }

```

If you need to set region, amis etc, in variables.tf, or use default, eu-west-1.  

NOTE: if you change ami id, make sure its ubuntu ami for this example to work.

For ssh to work, do the following.  
symlink or name your private ssh key pem file to my_aws_key.pem, I have the private key in ~/.aws dir.  ( This the private key part of your keypair name you're using in ssh_key_name variable above. )

simplist is to just symlink it.  (or you can update the main.tf to set it to path of your .pem file)

```
ln -s ~/.aws/akarim_ssh.pem ~/.aws/my_aws_key.pem

```

You can also add your own public key(s) in user_data file, alerta_data.conf, in section ssh_authorized_keys:, replace <ADDITONAL PUBKEYS> with your pubkey.

```
vi alerta_data.conf 
....

ssh_authorized_keys:
  - ssh-rsa <ADDITIONAL PUBKEYS>
```

Change consul id to avoid clash, set the consul_id to be unque to you, to avoid clash with someone else running this same time as you.

```
variable "consul_id" { default = "aka_alerta_demo" }
```
### Step 4 - Run to launch the instance
Run plan and apply when ready
```
$ terraform  plan
$ terraform apply
```

alerta should be ready to be tested at http://<EC2_PUBLIC_DNS>

you can also go to demo.consul.io to view the key that has been created in consul demo site. Remember this is demo site, so keys get reset back to default after a while.

TODO: 

Add hook in terraform to wait for cloud-init run to complete.

### Step 5 - Send test Alert to alerta
To send alert to the newly created instance.

Download alerta command-line tool.

```
pip install alerta
```
To use the command-line tool to submit a test alert you first need to create a configuration file that defines what API endpoint to use: This set to your newly created instance.

```
vi $HOME/.alerta.conf
[DEFAULT]
endpoint = http://<EC2_PUBLIC_DNS>/api

```

Send a test “critical” alert and confirm it has been received by viewing it in the web console:

```
$ alerta send --resource net01 --event down --severity critical --environment Development --service Network --text 'net01 is down.'

```

Note that the above can be shortened by using argument flags instead of the full argument names:
```
$ alerta send -r net01 -e down -s critical -E Code -S Network -t 'net01 is down.'
```

more details of alerta docs can be found here [http://docs.alerta.io/en/latest/design.html](http://docs.alerta.io/en/latest/design.html)

## NOTES on consul:
This example just demostrates use of consul provider in terraform, using the demo consul endpoint. If you have your own consul setup, then change the details in main.tf to point to your own consul endpoint. Goal here is set the alerta end point, so when launching other instances, we can retrieve the end point address using consul to know where to send our alerts to. 
Example is purely to show how one can do service discovery using consul.

## References
* [https://www.alerta.io/](https://www.alerta.io/)
* [https://www.consul.io/](https://www.consul.io/)
* [https://www.terraform.io/](https://www.terraform.io/)

