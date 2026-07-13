# /etc/ood/config/apps/dashboard/initializers/ood.rb
Rails.application.config.after_initialize do

  OodFilesApp.candidate_favorite_paths.tap do |paths|
    paths.clear()

    # add VSC paths
    envs = ["VSC_DATA", "VSC_SCRATCH", "VSC_DATA_VO_USER", "VSC_SCRATCH_VO_USER", "VSC_DATA_VO", "VSC_SCRATCH_VO"]

    # If path exists and is not the same as $HOME, add it
    envs.each do |env|
      if (ENV.has_key?(env) && ENV[env] != ENV["HOME"])
        paths << FavoritePath.new(Pathname.new(ENV[env]), title: "#{env}")
      end
    end

    # add an entry for each T1 project the user belongs to, e.g.
    # VSC_T1_PROJECTS=2026_055:2026_056 -> "#{VSC_SCRATCH_PROJECTS_BASE}/2026_055", "#{VSC_SCRATCH_PROJECTS_BASE}/2026_056"
    if ENV.has_key?("VSC_SCRATCH_PROJECTS_BASE") && ENV.has_key?("VSC_T1_PROJECTS")
      projects_base = ENV["VSC_SCRATCH_PROJECTS_BASE"]
      ENV["VSC_T1_PROJECTS"].split(":").each do |project|
        paths << FavoritePath.new(Pathname.new("#{projects_base}/#{project}"), title: "Project #{project}")
      end
    end

    #warn(paths.inspect)

    # add project space directories
    #projects = User.new.groups.map(&:name).grep(/^P./)
    #paths.concat projects.map { |p| FavoritePath.new("/fs/project/#{p}")  }

    # Project scratch is given an optional title field
    #"paths.concat projects.map { |p| FavoritePath.new("/fs/scratch/#{p}", title: "Scratch")  }
  end
end
