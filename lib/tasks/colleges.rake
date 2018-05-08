# frozen_string_literal: true

namespace :colleges do
  desc 'Seed an existing college with dummy data'
  task :seed, [:subdomain] => [:environment] do |_, args|
    CollegeSeeder.seed(subdomain: args.subdomain)
  end

  desc 'Provision a set of colleges and optionally seed them with dummy data'
  task :provision, [:url] => [:environment] do |_, args|
    filename = FileFetcher.fetch(url: args.url)
    CollegeProvisioner.provision(filename: filename, seed: env?('SEED'))
  end
end
