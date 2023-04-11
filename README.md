# Customized Devilbox for Laravel Development

This is just a copy of original [Devilbox repository](https://github.com/cytopia/devilbox). I just added some bash aliases and shell scripts to quickly start your Laravel Development.<br/>
To read more about Devilbox, please click the original [README](DEVILBOX.md).

## Installation

```shell
# Clone via HTTP
git clone https://github.com/luchmewep/laravel-devilbox.git devilbox

# Or, clone via SSH
git clone git@github.com:luchmewep/laravel-devilbox.git devilbox

# Go to Devilbox's folder
cd devilbox

# Start the basic Devilbox containers (php, httpd, bind) and mysql as well
./up.sh mysql redis
```

## Usage

### Custom Docker Shell Scripts

| Command | Script      | Description                                                                                                                                            |
|---------|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| Up      | `./up.sh`   | Starts the Devilbox basic containers which are `php`, `httpd`, and `bind`.<br/>Want to run `mysql` or `redis`? You can do this: `./up.sh mysql redis`. |
| Stop    | `./stop.sh` | Stops all running Devilbox containers. You can turn them back on with the `Up` script.                                                                 |
| Down    | `./down.sh` | Stops and deletes all Devilbox containers and their volumes. The deleted volumes are irrecoverable.                                                    |

**Note #1**: You don't need to run `./shell.sh` anymore since it's already included in the `Up` script.<br/>
**Note #2**: The databases will be included in the deleted volumes so make sure to back it up if necessary.

### Custom Bash Aliases for Devilbox Shell

| Alias          | What does it do?                                                             |
|----------------|------------------------------------------------------------------------------|
| `laravel_new`  | Creates a new Laravel app using `composer` inside the specified `vhost`.     |
| `git_clone`    | Clones a new Laravel app using `git` inside the specified `vhost`.           |
| `laravel_link` | Symlinks the `public` folder of your Laravel app to your `vhost`'s `htdocs`. |
| `php_change`   | Changes the PHP container of a `vhost`.                                      |
| `php_default`  | Changes the PHP container of a `vhost` to default.                           |


**Note #1**: These bash aliases are only usable inside the Devilbox terminal.<br/>
**Note #2**: Btw, these bash aliases can be found at `bash/aliases.sh`. You are free to add your own bash aliases or modify existing ones.<br/>
**Note #3**: These bash aliases will ask for user input when no arguments are provided.<br/>
**Note #4**: Make sure the PHP version of Devilbox terminal matches the to-be-created or to-be-cloned Laravel app.

## FAQs

#### 1. How to switch to a terminal with different PHP version?

To switch to a terminal with different PHP version, just add PHP container name after the `Up` script like this: `./up.sh php74`.<br/>
Refer to [docker-compose.override.yml](docker-compose.override.yml) for available PHP container names.<br/>
<br/>
If you will run multiple PHP versions, the first argument will be chosen for the PHP version of Devilbox terminal.<br/>
Example: Running `./up.sh php74 php80 php81` will open a terminal with PHP 7.4.

#### 2. How to run `redis` and/or `mysql`?

To run Redis and/or MySQL databases, just add them at the very end when you run the `Up` script like this: `./up.sh php74 mysql redis`.<br/>

#### 3. How to run `ngrok`?

To run Ngrok, just add it at the very end when you run the `Up` script like this: `./up.sh php74 ngrok`<br/>
Btw, the token used is mine so please replace it. You can find it at the very bottom of the [.env](.env) file.<br/>
I just followed this [official documentation](https://devilbox.readthedocs.io/en/latest/custom-container/enable-ngrok.html) from Devilbox when setting up Ngrok. Please refer to that if you encounter an issue.

#### 4. How to run `minio`?

To run Minio, just add it at the very end when you run the `Up` script like this: `./up.sh php74 minio`<br/>
Minio is an S3-compatible storage service. You can use it for local development if you don't have an S3 instance yet.

## Questions

If you have questions, feel free to send an email at [jamescarloluchavez@gmail.com](mailto:jamescarloluchavez@gmail.com).
