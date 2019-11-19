#!/usr/bin/env bash

# fswatch -uEe '.*/code_projects/.*/' --format '%t|%p|%f' ~/code_projects
# the idea with this script is to watch code_projects directory, then when a new directory is made
# it will create a project in local gitlab and commit the whole directory
# then it will watch the directory for any changes and create push it to the directory
# it will aggregate the changed directories and create directories so it only
# does a push/repo create every hour or so and do it all at once
# this will help me have a history of changes i've made and when
# also keep all changes in a pretty git ui
# also would be nice to watch changes in gitlab and pull when gitlab has stuff (ie if i change something in gitlab ui but not on disk)
# can also be done with git projects by adding another repo see (https://iridakos.com/tutorials/2018/03/01/bash-programmable-completion-tutorial.html)

# first check if gitlab is running (http://localhost:8929/)

# if it's not then download it from my github repo which should also have the create repo script and start it up docker-compose up -d

# fswatch ~/code_projects (create dir if not exist)
# fswatch -0 .|xargs -0 -n 1 -I {}
# store changed directory names in sqlite database with primary key on the name to avoid dupes
# also somehow watch gitlab (any hooks in gitlab for this?)

# then another process will kick off every hour and check for count(*) of table and if it has data then
# iterate over it and either create repo and push it to gitlab or simply push it gitlab



# Place in ~/Library/LaunchAgents
# Run launchctl load ~/Library/LaunchAgents/com.user.loginscript.plist and log out/in to test (or to test directly, run launchctl start com.user.loginscript)
# Tail /var/log/system.log for error messages.
# chmod a+x
# $HOME/Library/LaunchAgents
logdir=~/gitlab-watcher/logs
mkdir -p ${logdir}

token="F9zyUdjqi9pKo7QswLKu"
gitlab="localhost"
gitlaburl="http://$gitlab:8929"
gitlab_api(){
    curl -qs --header "PRIVATE-TOKEN: $token" -X $1 "$gitlaburl/api/v4/$2"
}
get_name_from_path(){
    IFS='/' read -ra ADDR <<< "$1"
    name=${ADDR[${#ADDR[@]}-1]]}
    echo ${name}
}
create_gitlab_project() {
    gitlab_api POST "projects?name=$(get_name_from_path $1)"
#    curl --header "PRIVATE-TOKEN: $token" -X POST "$gitlaburl/api/v4/projects?name=$name"
}
get_project_id(){
    gitlab_api GET "projects" | python -c "import json,sys;obj=json.load(sys.stdin);print [i['id'] for i in obj if i['name']=='$(get_name_from_path $1)'][0];"
}
rename_project(){
    gitlab_api PUT "projects/$(get_project_id $1)?name=$2"
}
delete_project(){
    gitlab_api DELETE "projects/$(get_project_id $1)"
}
commit_project(){
#    bash --rcfile <(echo ". ~/.bashrc;
    bash -c "
    cd $1
    git add .
    git commit -m \"$2\"
    git push ||  git push --set-upstream origin master
    "
}

initial_commit(){
#    bash --rcfile <(echo ". ~/.bashrc;
    bash -c "
    cd $1
    git init
    git remote add origin ssh://git@${gitlab}:2224/unsupo/$2.git
    [[ -f README.md ]] || echo \"$1\" > README.md
    git add .
    git commit -m \"Initial commit\"
    git push -u origin master
    "
}

watch_directory(){
    fswatch=/usr/local/bin/fswatch
    ${fswatch} -uEe '.*/gitlab/[data|logs]/*' -e '.*/\.git' --format '%t|%p|%f' ~/code_projects | while read event; do # Ee '.*/code_projects/.*/' # exclude # -l300 # latency
        IFS='|' read -ra ADDR <<< "$event"
        d=${ADDR[0]}
        p=${ADDR[1]}
        es=${ADDR[2]}
        IFS='/' read -ra pdARR <<< "$p"
        n=0
        for i in "${pdARR[@]}"; do
            if [[ ${n} == 1 ]]; then
                pd=${i}
                break
            fi
            if [[ "$i" == "code_projects" ]]; then
                n=1
            fi
        done
        IFS=' ' read -ra esARR <<< "$es"
        if [[ "${esARR[${#esARR[@]}-1]}" == "IsFile" ]]; then
            echo "commit_project \"~/code_projects/$pd\" ${event}"
            commit_project "~/code_projects/$pd" "${event}"
            continue
        fi
        if [[ ${p} =~ ".*/code_projects/.*/" ]]; then
            continue
        fi
        if [[ "${esARR[0]}" == "Created" && "${esARR[${#esARR[@]}-1]}" == "IsDir" ]]; then
            echo "create project ${p}"
            create_gitlab_project ${p}
            initial_commit ${p} $(get_name_from_path ${p})
        fi
        # TODO deleted directories should i just delete it from gitlab or rename it to deleted?
        if [[ "${esARR[0]}" == "Deleted" && "${esARR[${#esARR[@]}-1]}" == "IsDir" ]]; then
            echo "delete project ${p}"
            delete_project ${p}
        fi
    done
}

add_all_directories(){
    cdir=$(pwd)
    for d in $(ls -da ~/code_projects/*); do
        name=$(get_name_from_path ${d})
        if ! get_project_id ${name} 2>&1 >/dev/null; then
            echo "creating $name"
            create_gitlab_project ${name}
            initial_commit ${d} ${name}
        fi
    done
}

# this is for missed directories
add_all_directories
watch_directory

#delete_project test
#for d in $(ls -da ~/code_projects/*); do
#    delete_project $(get_name_from_path ${d})
#done

#delete_project $1