require 'md5'

module Lockrun

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest (none are needed by default):
  #
  #   configure(:lockrun => { :idempotent => true })
  #
  # Moonshine will autoload plugins, just call the recipe(s) you need in your
  # manifests:
  #
  #    recipe :lockrun
  def lockrun(options = {})
    # --no-check-certificate is needed because GitHub has SSL turned on all the time
    # but wget doesn't understand the wildcard SSL certificate they use (*.github.com)
    exec 'install_lockrun',
      :cwd => '/tmp',
      :command => [
        'wget https://github.com/pushcx/lockrun/raw/master/lockrun.c --no-check-certificate',
        'gcc lockrun.c -o lockrun',
        'cp lockrun /usr/local/bin/'
      ].join(' && '),
      :creates => lockrun_path
  end

private
  # Use this command to pass a properly formatted command
  # to the cron helper method:
  #
  #     cron 'my:cool:job', :command => lockrun_wrapped_command('/path/to/my/command work'), :user => configuration[:user], :minute => 55
  def lockrun_wrapped_command(command)
    options = configuration[:lockrun]

    command_options = []
    command_options << "--lockfile=/tmp/#{MD5.hexdigest(command)}.lockrun"
    command_options << "--idempotent" if options[:idempotent]
    command_options << "--maxtime=#{options[:maxtime]}" if options[:maxtime]
    command_options << "--wait" if options[:wait]
    command_options << "--verbose" if options[:verbose]

    "#{lockrun_path} #{command_options.join(" ")} -- #{command}"
  end

  def lockrun_path
    "/usr/local/bin/lockrun"
  end
end
