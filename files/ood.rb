# /etc/ood/config/apps/dashboard/initializers/ood.rb
Rails.application.config.after_initialize do

  OodFilesApp.candidate_favorite_paths.tap do |paths|
    paths.clear()

    # add VSC paths
    envs = ["VSC_DATA", "VSC_SCRATCH", "VSC_DATA_VO_USER", "VSC_SCRATCH_VO_USER", "VSC_DATA_VO", "VSC_SCRATCH_VO"]

    envs.each do |env|
      if (ENV.has_key?(env))
        paths << FavoritePath.new(Pathname.new(ENV[env]), title: "#{env}")
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
