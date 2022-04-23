#!/usr/bin/ruby
require "rubygems"
require "json"
require "pp"

##
## Automatically apply remove role recommendations
## see: https://cloud.google.com/iam/docs/recommender-overview

def removeRole(action, recommendation_id, etag, project_name, dryrun, ignore_list)
  path = action["pathFilters"]
  member = nil
  role = nil
  path.each do |k, v|
    if k.include? "members"
      member = v
    end
    if k.include? "role"
      role = v
    end
  end

  if member.nil?
    return false
  end
  if role.nil?
    return false
  end

  if ignore_list.any? { |text| member.include? text }
    pp "ON IGNORE LIST, SKIPPING: " + member
    return false
  end

  remove_role_cmd = "gcloud projects remove-iam-policy-binding " + project_name + " --member=" + member + " --role=" + role + " --format=json"
  pp remove_role_cmd
  if !dryrun
    pp "RUNNING: " + remove_role_cmd 
    remove_role_cmd_output = system(remove_role_cmd)
    pp "OUTPUT: " + remove_role_cmd_output
  end
  return true
end

if ARGV.length < 1
  puts "To run: " + __FILE__ + " [project_name]"
  exit
end

ignore_list = []
if !ARGV[1].nil?
  ignore_list = ARGV[1].split(",")
end

dryrun = ARGV.any? { |text| text.include? "dryrun" }

pp "IGNORE LIST: " + ignore_list.join(",")
pp "DRY RUN: " + dryrun.to_s

project_name = ARGV[0]
puts project_name
cmd_recommendations = "gcloud  recommender recommendations list  --project=#{project_name} --location=global  --recommender=google.iam.policy.Recommender"
pp `#{cmd_recommendations}`

recommendations = `#{cmd_recommendations} --format=json`
recommendJson = JSON.parse(recommendations)
recommendJson.each do |item|
  recommendation_id = item["name"].split("/")[-1]
  operations = item["content"]["operationGroups"].first["operations"]
  etag = item["etag"]
  operations.each do |action|
    if action["action"] == "remove"
      removeRole(action, recommendation_id, etag, project_name, dryrun, ignore_list)
    end
  end
end
