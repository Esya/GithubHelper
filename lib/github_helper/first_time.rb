require 'io/console'

# First time run ? Let's make the config file !
class GithubHelper::FirstTime
  include HTTParty
  base_uri 'https://api.github.com'

  # Outputs the string as a question then waits for the user input
  def ask(string,hidden=false,default=nil)
    puts string
    if hidden
      input = STDIN.noecho {|i| i.gets}.chomp
     else
      input = gets.strip
    end
    puts ""
    input = (input == "") ? default : input
  end

  # This let us get the OAuth token
  def getToken(user,password)
      data = {:scopes => ["repo"], :note => "GithubHelper Gem"}
      resp = self.class.post("/authorizations",:body => data.to_json)

      if resp.headers['status'][0..2].to_i != 201
        raise "Can't get the OAuth token : Wrong credentials, please try again"
      end

      resp.parsed_response["token"]
  end

  def initialize()
    @config = Hash.new()
    @config = {'credentials' => {'user' => '', 'token' => ''}, 'remote' => {'user' => '', 'repo' => ''}}

    fillArray!
  end

  # Interactive building of the YAML file.
  def fillArray!
    puts "Setting your credentials"
    user = ask("What's your github user name (Won't work with your email) ?")
    password = ask("What's your git password ?\n(This won't be logged, used to get an OAuth token)",true)
    self.class.basic_auth user, password

    @config['credentials']['user'] = user
    @config['credentials']['token'] = getToken(user,password)

    puts "Now let's set up your repo you want to send your pull requests to"
    @config['remote']['user'] = ask("What's the user you want to send your pull requests to ? ")
    @config['remote']['repo'] = ask("What's the user's repo ?")

    puts "Writing to config file : .git/githelper.config.yml"
    header = "# GithubHelper config file\n# You can edit your configuration here\n"
    yaml = @config.to_yaml

    output = header + yaml
    begin
        File.open('.git/githelper.config.yml', 'w') {|f| f.write(output) }
    rescue Exception
        puts "Can't write to .git/githelper.config.yml, are you sure this a git directory?"
        raise
    end

  end
end