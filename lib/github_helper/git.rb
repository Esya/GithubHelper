# This is a little hack to the Git gem to add a way to check the staged files
# And also to forcepush a branch.
module Git
  class Status
    public

    # A file about to be commited has a type and a sha_index
    def staged
      @files.select { |k, f| f.sha_index != "0000000000000000000000000000000000000000" && f.type != nil }
    end
  end

#The git gem doesn't include a way to force push, let's implement it !
  class Base
    public
    def forcepush(remote = 'origin', branch = 'master')
      self.lib.forcepush(remote, branch)
    end
  end

  class Lib
    public
    def forcepush(remote, branch)
      command('push -f', [remote, branch])
    end
  end
end