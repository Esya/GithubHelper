# GithubHelper
This useful little gem allows you **in a single command** to commit your staged changes, push them to your remote repository, and open a pull request for those changes. 

Usually, when you have a quick fix to submit for an upstream repository, you would have to : 

* Commit your fix
* Push your fix to your repository
* Go to your repository on Github
* Open a pullrequest and type the title/description
* Submit the pullrequest *(And you won't know if it's mergeable)*

GithubHelper does all that for you just with :

	ghh -fm "Fixing a bug"
Or

	git commit -m "Fixing a bug"
	ghh -f

## Installation

Just install the gem using :

    gem install github_helper

## Configuration
The first time you run a `ghh` command in your git repository, a prompt will ask you your credentials (**But won't store** your password, only the OAuth token) and your target user/repo.

It will then save the configuration in `.git/githelper.config.yml`  

## Usage
The **"fast mode"** just needs the `-f` option. It will take your latest commit message and use it as the Pull request's title. Optionnaly, you can use `-fm [message]` to commit/push/open the PR. 

To add an issue ID to the Pull request's description, just use the `-i` option.

To get some more help, just run `ghh -h`

Here are the detailed options :

    -f, --fast                       Fast mode : push to origin & pull-request
    -r, --request                    Creates a pull request
    -c, --commit                     Commit staged changes
    -m, --message [message]          Your commit message
    -i, --id [id]                    Issue ID
        --reset-config               Resets your YML config file and enter your data again.
    -l, --pulls                      Lists the open pull requests
    -t, --title [TITLE]              Pull request title. (Defaults to latest commit)
    -d, --description [BODY]         Pull request description. (Defaults to an empty string)
    -b, --base [master]              Pull request base. (Defaults to master)
    -p, --push                       Push branch to remote before doing the pullrequest(To username/currentbranch)
    -n, --head [head]                Pull request head (Defaults to current branch)
    -v, --verbose                    Enables verbose mode
    -h, --help                       Displays this screen

### ToDo list
* More documentation
* A commit-amending feature ?
* A better error handling
* Share a single token over multiple repos