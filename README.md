# Simple CI Template

## General information
This template can be used for the setting up the simplest CI process using [Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines).

This CI process is used for the creation separate environment on the server for the each branch.
The links to the built environments are created using [xip.io](http://xip.io/) service.

The flow was created for the following stack on the server: Ubuntu, Apache, MySQL.

## How it works
The idea of this template is creation separate environments on the server for each active branch of the project's repository.
It may be useful for the testing features independently or for the setting up the deployment process.


## Configuration steps
### 1. Add server access config
- You need to create a user on the server or use existing one, which has enough permissions to create folders, add virtual hosts, and reload Apache. 
- Save user's credentials into _./project/ci/config.sh_ file.
- Change _SCRIPTS_DIR_ variable to the folder, which will contain the build scripts. 

### 2. Generate RSA keys for the deployment
- Generate you local pair of the RSA keys:
```
ssh-keygen 
```
- Copy the content of the private key into _./project/ci/id_rsa_ci_:
```
cp ~/.ssh/id_rsa ./project/ci/id_rsa_ci
```
- Add your public key to the server.

  - Get content of your public key:
  ```
  cat ~/.ssh/id_rsa.pub 
  ```
  - Login to the server, open/create file _~/.ssh/authorized_keys_.
  - Add the content of _id_rsa.pub_ into _authorized_keys_.

More information about SSH keys can found into [Set up an SSH key](https://confluence.atlassian.com/x/7w0zDQ) page.

### 3. Create CI DB user
You may need some specific DB user for the manipulations with the databases or use the existing one.
- Create new user:
```
CREATE USER 'ci'@'localhost' IDENTIFIED BY 'ci_pass';
GRANT ALL PRIVILEGES ON *.* TO 'ci'@'localhost';
```
- Save DB user's credentials into _./server/config.sh_ file.

More information about adding users account can be found on the [official documentation](https://dev.mysql.com/doc/refman/5.7/en/adding-users.html) page.

### 4. Add access key to the Bitbucket
- Create RSA keys on the server.
- Add access key to the repository according to the [documentation](https://confluence.atlassian.com/x/I4CNEQ).

### 5. Set up Slack Integration
- Set up Slack Incoming Webhook according to the [documenation](https://api.slack.com/incoming-webhooks).
- Save channel name and webhook URL into _./server/config.sh_ file.

### 6. Configure the deploy script
Open _./server/config.sh_ file, and set up the variables:
- **REPO** - Bitbucket repository into SSH format: _git@bitbucket.org:account/repo.git_;
- **SITES_ROOT** - the directory where you host your sites;
- **BUILDS_ROOT** - the subdirectory used for the builds;
- **DB_USER** - CI DB user name; 
- **DB_PASS** - CI DB user password;
- **DB_NAME_LENGTH** - the length of the generated databases' names;
- **SLACK_CHANNEL** - Slack notification channel;
- **SLACK_WEBHOOK** - Slack incoming webhook URL;
- **SLACK_USERNAME** - Slack notification user name;
- **SLACK_ICON** - Slack notification icon;
- **DOMAIN_NAME** - top-level domain name;
- **SITE_TITLE** - site title.

### 7. Upload the deployment code to the server
- Upload all files from the _./server/_ folder to the directory defined in _SCRIPTS_DIR_ variable of the _./project/ci/config.sh_ file.
- Set up the executive permissions on the files _build.sh_ and _cleanup.sh_.

### 8. Enable Pipelines
- Copy the content of _./project/_ folder to the root of your project (_master_ branch) and push in to the repository.
- Open _Pipelines_ tab in Bitbucket and enable the pipelines.

### 9. Set up clean up job
- Set up cron job on the server, which executes _cleanup.sh_ script.
```
$ crontab -e
0 */6 * * * /root/cleanup.sh
```
Crontab rules can be configures using [Crontab.guru](https://crontab.guru/every-6-hours) service.
