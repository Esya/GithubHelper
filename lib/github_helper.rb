require "github_helper/version"
require "github_helper/git"
require "json"
require "HTTParty"
require "git"
require "pp"

module GithubHelper
  class Github
    include HTTParty

    base_uri 'https://api.github.com'

    @current_branch = ''

    @verbose = false
    @@target_user = ''
    @@target_repo = ''

    attr_accessor :options

    # Display the open pull requests on the target repo
    def displaypulls!
      puts "Pull requests for #{@@target_user}/#{@@target_repo}\n"
      pulls = get("/repos/#{@@target_user}/#{@@target_repo}/pulls")
      pp pulls if @verbose
      checkHeaders(pulls)
      pulls.each { |pull| print "*\t"+pull['title'] + "\t" + pull['user']['login'] + "\n" } 
    end

    def initialize(options)
      @config = YAML::load( File.open( '.git/githelper.config.yml' ) )

      # Credentials setting from YML
      @@my_user = @config['credentials']['user']
      @@my_token = @config['credentials']['token']

      # Remote settings from YML
      @@target_user = @config['remote']['user']
      @@target_repo = @config['remote']['repo']

      @options = options
      @verbose = true if options[:verbose]
      @currentBranch = ''
      @Git = Git.open('.');
      @@my_name = @Git.config['user.name']
    end

    def get(url)
      self.class.get(url+"?access_token=#{@@my_token}")
    end

    def post(url,data)
      self.class.post(url+"?access_token=#{@@my_token}",data)
    end

    # Creates a pull request
    def createPull!
      # Formats the HEAD to user:branch
      head = @@my_user+':'+currentBranch?

      # Do we have a title ? If not, takes it from the last commit
      pullTitle = (@options[:pulltitle] == false) ? lastCommit? : @options[:pulltitle]

      body = @options[:pullbody]
      body = "#{body}\n##{options[:issueid]}\n" if (options[:issueid] != false)

      data = {:title => pullTitle, :body => body, :base => @options[:base], :head => head}
      pp data if @verbose
      puts "Asking for #{data[:head]} to be merged into #{@@target_user}/#{data[:base]}"

      # Let's send the request
      resp = post("/repos/#{@@target_user}/#{@@target_repo}/pulls", :body => data.to_json)
      pp resp if @verbose
      checkHeaders(resp)

      # So far so good. Lets check if it's mergeable and give the user the proper link
      puts "Pull request succeeded. Getting more informations..\n"

      infos_resp = get("/repos/#{@@target_user}/#{@@target_repo}/pulls/"+resp.parsed_response['number'].to_s)
      pp infos_resp if @verbose
      checkHeaders(infos_resp)

      infos = infos_resp.parsed_response

      puts 'Url : '+infos['_links']['html']['href']
      if(infos['mergeable'])
        puts 'Your pull request is mergeable.'
      else
        puts "/!\\ ..But your pull request cannot be merged. Try to rebase then push again. /!\\"
      end
    end

    # Commits staged changes
    def commit!
      if(options[:commitmessage])
        #Do we have files to commit ?
        count = @Git.status.staged.count

        raise Exception, "You have no staged files, aborting your commit" if (count == 0)

        message = options[:commitmessage]

        ci = @Git.commit(message)
        pp ci
      else
        raise Exception, "Commit needs a message"
      end
    end

    # Do we have a good HTTP status ?
    def checkHeaders(resp)
      code = resp.headers['status'][0..2];

      #If the status isnt 200 (OK) or 201 (Created), raise an exception
      good = case code.to_i
      when 200..201 then true
      when 401 then 
        raise Exception, "Bad credentials, maybe your OAuth token isn't valid anymore.\nReset your config with ghh --reset-config and try again"
      else
        error = formatError(resp)
        raise Exception, "Error (HTTP #{code}) : "+error
      end
      good
    end

    # Format errors from the github api
    def formatError(resp)
      output = "";

      output << resp.parsed_response['message'];
      if(resp.parsed_response['errors'] != nil)
        resp.parsed_response['errors'].each { |e| 
          output << "\n" + e['message'] if e['message'] != nil
        }
      end
      output
    end

    # Push the branch to origin
    def pushBranch!
      @Git.forcepush('origin',currentBranch?)
      puts "Pushed #{@currentBranch} to origin"
    end

    # Return your last commit's title
    def lastCommit?
      message = ''
      @Git.log(1).author(@@my_name).each { |c| message = c.message }
      message.split("\n")[0]
    end

    # Return your current branch's name
    def currentBranch?
      if(@currentBranch == '')
        @currentBranch = `git branch | grep '*' | cut -d " " -f2`.strip!
      end
      @currentBranch
    end
  end
end
