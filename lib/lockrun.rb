module Lockrun

  # Moonshine will autoload plugins, just call the recipe(s) you need in your
  # manifests:
  #
  #    recipe :lockrun
  def lockrun(options = {})
    # --no-check-certificate is needed because GitHub has SSL turned on all the time
    # but wget doesn't understand the wildcard SSL certificate they use (*.github.com)
    exec 'install_xsendfile',
      :cwd => '/tmp',
      :command => [
        'wget https://github.com/pushcx/lockrun/raw/master/lockrun.c --no-check-certificate',
        'gcc lockrun.c -o lockrun',
        'cp lockrun /usr/local/bin/'
      ].join(' && '),
      :creates => '/usr/local/bin/lockrun'
  end

  # Use this command to pass a properly formatted command
  # to the cron helper method:
  #
  #     cron 'my:cool:job', :command => lockrun_wrapped_command('my_cool_job', '/path/to/my/command work'), :user => configuration[:user], :minute => 55
  def lockrun_wrapped_command(name, command)
    "/usr/local/bin/lockrun --lockfile=/tmp/#{name}.lockrun -- #{command}"
  end
end
