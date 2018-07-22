# FreeBSD ZFS-enabled packer

To use:

- Install packer
- Install AWS cli tools
- Set up user access keys on your AWS account

With all this done, just clone this repo and build your own image.

    git clone https://github.com/queerbsd/fbsdzfs-ec2imager.git
    cd fbsdzfs-ec2imager
    ./build_img 11.2-RELEASE

For using with alternate AWS profiles, pass in as an evironment variable,
e.g.:

    env AWS_PROFILE=leeron ./build_img 11.0-RELEASE

**Notes**

  The product-code filter for FreeBSD in the aws-marketplace differs based
  on the major relase version. Add the following line as necessary to the
  "filters" in fbsdzfs-base.json, or leave out altogether (not recommended,
  but this is the default for friendly use). 

  - For FreeBSD 10 Releases: "product-code": "dxlde6kbuza4cb7ero2ny5lqj"
  - For FreeBSD 11 Releases: "product-code": "b5c1v52b2tam17wi8krmj4e77"

## Advanced Builder: ZFS Jailhost

To build a ZFS image with ezjail installed on the host, add the additional
environment parameter 'PURPOSE=ezjail'.

    env AWS_PROFILE=leeron PURPOSE=ezjail ./build_img 10.3-RELEASE

This will use the alternate packer script fbsdzfs-ezjail.json.

**Notes**

  **ONLY WORKING ON 10.3-RELEASE**

  The method to install ezjail's basejail requires unpacking hardlinks through
  a symlink, possibly addressed previously. For some reason this error has been
  re-introduced as of 10.4-RELEASE, which means the method is broken and the
  ezjail base installation must be repeated before the jails will start.

  See the scripts `create_jail_example.sh` and `jail_example_pkg_install.sh`.
  They can be tried by setting 'PURPOSE=ejzail-testjail' instead to use the
  alternative builder.

## Setting Up An AWS Account

Since the signup procedure for an AWS account is so straightforward, I’m not
going to go into this in depth. In short: have an email address, create an
Amazon account (or use your existing one), and [create an AWS
account](https://portal.aws.amazon.com/billing/signup#/start). All you'll need
during the signup process is

- a credit card for billing (Amazon will authorize a charge of 1.00 USD to
  prove the card)
- a phone number during the signup process (An automated call will be made to
  this number to prove your identity)

What we’ll focus on here instead is what happens after you’ve created your
account. If the first thing you wonder is *what do I do now?*, then this is
what you do now. 

### Creating an IAM User

The root user for an AWS account should normally be reserved for billing
issues. To interact with your setup, use instead an IAM account with
semi-restricted permissions to avoid anyone else acquiring your information and
abusing it to rack up charges. AWS Support has been known to be accommodating
for issues surrounding identity or service theft, but best practice can prevent
you from needing to rely on Amazon's good will.

To start off on the right foot with IAM, make your life easier. The console
login for IAM users is different than the login for the account root user, so
having a URL to access the console directly helps. First log into the [AWS
Console's IAM
Page](https://console.aws.amazon.com/iam/home?region=eu-west-1#/home) as the
root user. Before you create a new IAM user for running packer jobs, first take
a moment to "customize" the Console login url, at the top of the IAM Dashboard.
I'm using, for example,
[https://qbsd.signin.aws.amazon.com/console](https://qbsd.signin.aws.amazon.com/console)
for ease of access (since "queerbsd" was, surprisingly already taken).

Second, you'll want to add a Multi-Factor Authentication (MFA) device to your
root account. Although this isn't strictly necessary, it is *extremely* bad
practice to not include MFA. I can recommend Google Authenticator as a virtual
MFA device, as it is an easy, free, and safe way to help lock down your root
user's access.

Third, create a new user using the dialog provided. This will take you through
creating a new account, and creating a group with permissions set for the new
user. 

#### IAM User Creation: Step One 

For the first part of the dialog, pick a name. The literal login name you use
is easiest as $USER will be picked up from your shell, but I've picked `leeron`
for demonstrating how to modify this when running the packer scripts. At least
be sure to check both these boxes:

- [√] Programmatic Access
- [√] AWS Management Console Access

Since this is your own user, feel free to generate and set a Custom password
for the new IAM user account. Take note though that the user account will need
the IAMUserChangePassword policy attached to their user, or to the group you'll
create for them– unless you want to always delegate updating access rights from
the root account.

#### IAM User Creation: Step Two

The second part of the dialog takes you through creating a group for the new
user. I've used "QBSDEc2ImageBuilder" as a group name, then attached the
following managed policies which are needed for building and testing an FbsdZFS
image.

- AWSMarketplaceFullAccess
- AmazonEC2FullAccess
- AmazonVPCReadOnlyAccess
- IAMUserChangePassword

Just a note on user permissions: AWS permissions are hugely complex. For a good
example of more fine-grained permission possibilities, take a closer look at
the IAMUserChangePermission (i.e., "show policy"). For now we'll stick to
Managed Policies for ease of use.

#### IAM User Creation: Steps Three & Four

Step three is only a quick review of the user you're about to generate. If
anything looks incorrect, you can stop and change it here before proceeding
with the "Create User" button.

Step four shows you the access credentials for the new user. **This is the only
time these credentials are available**, so we'll pause here and take you
through the local side of configuring your new user's access rights. 

If you close the browser window or forget to copy the user permissions, you'll
need to navigate in the IAM Dashboard to Users >> \<your username\> >> Security
Credentials, and update both the user's Console password, revoke the old Access
Key, and generate a new one.

### Configuring Your AWS CLI User

This portion presumes you're already using a reasonably unix- or linux-like OS. 

#### Install AWS CLI Tools

The first thing to do is install the AWS CLI, if you haven't already. This tool
uses a python library called "boto3" and provides a set of scripts based on
this library to connect to the AWS API and run actions. You have two options at
this point:

- Use your local package manager to install either `awscli` or `py27-awscli`.
  Naming conventions may vary.
- If you have Python's `virtualenv` installed, set up a virtualenv and run the
  awscli from there. For instance, after running git-clone on the the
  fbsdzfs-ec2imager, you could easily just do this:

    virtualenv fbsdzfs-ec2imager
    cd ./fbsdzfs-ec2imager
    source bin/activate
    pip install awscli

#### Configure AWS CLI With Access Keys
    
Whichever way you choose to run this, next just configure the access keys using
the `aws configure` utility. If you run this with no parameters, you'll create
a *default* profile for connecting. Here I'll set up a *specific* profile for
"leeron" with dummy credentials.

    $ aws --profile leeron configure 
    AWS Access Key ID [None]: AKIAJXMVPCF22XP4S6UQ
    AWS Secret Access Key [None]: 1XoGNY/krd3IQkJYr8hrQDmJ93nYB8yPBE9VUihW
    Default region name [None]: us-east-1
    Default output format [None]: json

I can test leeron's access now, by running something like

    env AWS_PROFILE=leeron aws ec2 describe-instances

### Confirming Access for Packer

Some "gotchas" before you run the builder:

- AWS checks your local clock when you make calls to the API. If your
  computer's clock is more than a minute behind, all calls will return an
  unspecified authorization error.

- The Free Tier for new users of AWS allows t2.micro instances for building
  images at no cost. The initial release of fbsdzfs-ec2imager used t2.large
  instances for the build to help speed the data-dependent process of downloading
  the source files and base packages. The latest version has been updated to
  avoid inflicting fees on users, but check the "instance_type" value to confirm
  that this is in fact using a t2.nano or t2.micro instance, or you will be
  charged (a very minor fee) for the hour that the packer builder image was
  started in.

- At this point you should already be able to run the fbsdzfs-ec2imager packer
  script, using the default VPC settings that AWS sets up for you when you
  create an account. A prequisite is *subscribing* to the FreeBSD instance you'll
  need to launch in order to run the build. This is self-explanatory when the
  packer build runs, as it will spit out an error like this:

        ==> amazon-ebssurrogate: Error launching source instance: OptInRequired: In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please visit https://aws.amazon.com/marketplace/pp?sku=b5c1v52b2tam17wi8krmj4e77

To avoid the error, "subscribe" to the Marketplace AMI you intend to build from
(these are split into different products, one for each major FreeBSD release
version)

- [Subscribe to FreeBSD 10 AMIs](https://aws.amazon.com/marketplace/pp/B00KSS55FY/)
- [Subscribe to FreeBSD 11 AMIs](https://aws.amazon.com/marketplace/pp/B01LWSWRED/)
