# Customized Devilbox for Laravel and NodeJS Development

This is just a copy of original [Devilbox repository](https://github.com/cytopia/devilbox). I just added some bash aliases and shell scripts to quickly start your Laravel and NodeJS Development.<br/>
<br/>
To learn more about Devilbox, please take a look at the original [README](DEVILBOX.md) or visit the [official documentations](https://devilbox.readthedocs.io).

## Installation

```shell
# Clone via HTTP
git clone https://github.com/luchmewep/simple-devilbox.git devilbox

# Or, clone via SSH
git clone git@github.com:luchmewep/simple-devilbox.git devilbox

# Go to Devilbox's folder
cd devilbox

# Start the basic Devilbox containers (php, httpd, bind), another PHP containers, as well as MySQL, Redis, and Minio
./up.sh mysql redis minio php54 php74 php82
```

## Usage

### Custom Docker Shell Scripts

| Command | Script      | Description                                                                                                                                            |
|---------|-------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| Up      | `./up.sh`   | Starts the Devilbox basic containers which are `php`, `httpd`, and `bind`.<br/>Want to run `mysql` or `redis`? You can do this: `./up.sh mysql redis`. |
| Stop    | `./stop.sh` | Stops all running Devilbox containers. You can turn them back on with the `Up` script.                                                                 |
| Down    | `./down.sh` | Stops and deletes all Devilbox containers and their volumes. The deleted volumes are irrecoverable.                                                    |

**Note #1**: You don't need to run [./shell.sh](shell.sh) anymore since it's already included in the `Up` script.<br/>
**Note #2**: The databases will be included in the deleted volumes so make sure to back it up if necessary.

### Custom Bash Aliases for Devilbox Shell

#### Main Functions

| Alias           | What does it do?                                                         |
|-----------------|--------------------------------------------------------------------------|
| `laravel_new`   | Creates a new Laravel app using `composer` inside the specified `vhost`. |
| `laravel_clone` | Clones a new Laravel app using `git` inside the specified `vhost`.       |
| `next_new`      | Creates a new NextJS app using `npx` inside the specified `vhost`.       |
| `next_clone`    | Clones a new NextJS app using `git` inside the specified `vhost`.        |
| `gatsby_new`    | Creates a new GatsbyJS app using `npx` inside the specified `vhost`.     |
| `gatsby_clone`  | Clones a new GatsbyJS app using `git` inside the specified `vhost`.      |
| `vite_new`      | Creates a new ViteJS app using `npx` inside the specified `vhost`.       |
| `vite_clone`    | Clones a new ViteJS app using `git` inside the specified `vhost`.        |
| `astro_new`     | Creates a new AstroJS app using `npx` inside the specified `vhost`.      |
| `astro_clone`   | Clones a new AstroJS app using `git` inside the specified `vhost`.       |

#### Other Functions

| Alias         | What does it do?                                                     |
|---------------|----------------------------------------------------------------------|
| `symlink`     | Symlinks the `public` folder of your app to your `vhost`'s `htdocs`. |
| `php_change`  | Changes the PHP container of a `vhost`.                              |
| `php_default` | Changes the PHP container of a `vhost` to `default`.                 |
| `port_change` | Changes the port number of a `vhost` for reverse proxy.              |

**Note #1**: These bash aliases are only usable inside the Devilbox terminal.<br/>
**Note #2**: These bash aliases can be found at the [bash folder](bash). You are free to add your own bash aliases or modify existing ones.<br/>
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

#### 5. How to fix multiple NodeJS apps trying to run on the same port number?

When running multiple NodeJS apps at the same time, there is a possibility that the designated port number is already taken.
And if the port is already taken, it's possible that when you visit your app, it will display the other app or show a Nginx error.
That is because your app's Devilbox config should be updated with the port change.

To fix this, just run the `port_change` bash function. It will ask for your app's `vhost name` and `port number` where it is currently running.
Don't forget to press `Reload` on `C&C` page afterwards.

## Questions

If you have questions, feel free to send an email at [`jamescarloluchavez@gmail.com`](mailto:jamescarloluchavez@gmail.com).
