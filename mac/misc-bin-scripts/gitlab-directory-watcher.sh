#!/usr/bin/env bash

# fswatch -uEe '.*/$dir_name/.*/' --format '%t|%p|%f' ~/$dir_name
# the idea with this script is to watch $dir_name directory, then when a new directory is made
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

# fswatch ~/$dir_name (create dir if not exist)
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

# TODO make this work for existing git repos IE the ones in ~/git and ~/gitwork this will help in file recovery and documentation
# TODO turn the gitlab methods into a separate bin script

logdir=~/log
mkdir -p ${logdir}
dir_name=code_projects
dir=~/${dir_name}/

# this is a localhost token so it probably isn't an issue in git
token="F9zyUdjqi9pKo7QswLKu"
gitlab="localhost"
gitlaburl="http://$gitlab:8929"
gitlab_api(){
    [[ -z $1 ]] && { echo "Must pass HTTP Method name got: $1"; return; }
    [[ -z $2 ]] && { echo "Must pass HTTP relative url ie projects/ name got: $2"; return; }
    curl -qs --header "PRIVATE-TOKEN: $token" -X $1 "$gitlaburl/api/v4/$2"
}
get_name_from_path(){
    IFS='/' read -ra ADDR <<< "$1"
    name=${ADDR[${#ADDR[@]}-1]]}
    echo ${name}
}
create_gitlab_project() {
    [[ -z $1 ]] && { echo "Must pass project name got: $1"; return; }
    gitlab_api POST "projects?name=$(get_name_from_path $1)"
#    curl --header "PRIVATE-TOKEN: $token" -X POST "$gitlaburl/api/v4/projects?name=$name"
}
get_project_id(){
    [[ -z $1 ]] && { echo "Must pass project name got: $1"; return; }
    gitlab_api GET "projects" | python -c "import json,sys;obj=json.load(sys.stdin);print [i['id'] for i in obj if i['name']=='$(get_name_from_path $1)'][0];"
}
rename_project(){
    [[ -z $1 ]] && { echo "Must pass project name got: $1"; return; }
    [[ -z $2 ]] && { echo "Must pass new project name got: $2"; return; }
    gitlab_api PUT "projects/$(get_project_id $1)?name=$2&path=$2"
}
delete_project(){
    [[ -z $1 ]] && { echo "Must pass project name got: $1"; return; }
    gitlab_api DELETE "projects/$(get_project_id $1)"
}

add_all_directories(){
    for d in $(ls -da ${dir}*); do
        name=$(get_name_from_path ${d})
        if ! get_project_id ${name} 2>&1 >/dev/null; then
            echo "creating $name"
            create_gitlab_project ${name}
            initial_commit ${d} ${name}
        fi
    done
}

delete_removed_directories(){
    all_projects=$(gitlab_api GET "/projects" | python -c "\
import json,sys
obj=json.load(sys.stdin)
print '|'.join([i['name'] for i in obj ]);\
    ")
    IFS='|' read -ra ADDR <<< "$all_projects"
    for i in "${ADDR[@]}"; do
        [[ ${i} == deleted-* ]] && continue
        if ! ls ${dir}${i} >/dev/null 2>&1; then
            echo "deleted $i, renaming project in gitlab"
            rename_project ${i} "deleted-$i-$(date +%s)"
        fi
    done
}

initial_commit(){
    [[ -z $1 && ! -d $1 ]] && { echo "Must pass valid directory instead got: $1"; return; }
    [[ -z $2 ]] && n=$(get_name_from_path $1) || n=$2
    bash -c "
    cd $1 || exit 1
    git init
    git remote add origin ssh://git@${gitlab}:2224/unsupo/$n.git
    [[ -f README.md ]] || echo \"$1\" > README.md
    git add .
    git commit -m \"Initial commit\"
    git push -u origin master
    " || delete_removed_directories
}
commit_project(){
    [[ -z $1 && ! -d $1 ]] && { echo "Must pass valid directory instead got: $1"; return; }
    [[ -z $2 ]] && m=$(date) || m = $2
    bash -c "
    cd $1 || exit 1 # git repo no longer exists?
    git add . || exit 2
    git commit -m \"$m\"
    git push || git push --set-upstream origin master
    "
    PC=$?
    [[ ${PC} -eq 1 ]] && { echo "$? deleting removed directories"; delete_removed_directories; }
    [[ ${PC} -eq 2 ]] && { echo "$? initial commit"; initial_commit $1 $(get_project_id $1); }
}

commit_all_directories(){
    for d in $(ls -da ${dir}*); do
        commit_project ${d} $(date)
    done
}

create_and_commit(){
    (
    create_gitlab_project $1;
    initial_commit $1 $2;
    )
}

init(){
    add_all_directories
    commit_all_directories
    delete_removed_directories
}

watch_directory(){
    fswatch=/usr/local/bin/fswatch
    ${fswatch} -uEe '.*/gitlab/[data|logs]/*' -e '.*/\.git' --format '%t|%p|%f' -l5 ~/${dir_name} | while read event; do # Ee '.*/$dir_name/.*/' # exclude # -l300 # latency
        echo '-----------------------------------------------------'
        date
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
            if [[ "$i" == "$dir_name" ]]; then
                n=1
            fi
        done
        IFS=' ' read -ra esARR <<< "$es"
        if [[ "${esARR[${#esARR[@]}-1]}" == "IsFile" ]]; then
            echo "commit_project \"$dir$pd\" ${event}"
            commit_project "$dir$pd" "${event}"
            date
            echo '-----------------------------------------------------'
            continue
        fi
        if [[ ${p} =~ ^.*/\$dir_name/.*/$ ]]; then
            echo "continuing because this is a subdirectory $p"
            date
            echo '-----------------------------------------------------'
            continue
        fi
        if [[ "${esARR[0]}" == "Created" && "${esARR[${#esARR[@]}-1]}" == "IsDir" ]]; then
            echo "create project ${p}"
            create_and_commit ${p} $(get_name_from_path ${p})
        fi
        # TODO deleted directories should i just delete it from gitlab or rename it to deleted?
        if [[ "${esARR[0]}" == "Deleted" && "${esARR[${#esARR[@]}-1]}" == "IsDir" ]]; then
            echo "deleted project ${p}, renaming to deleted-$p"
#            delete_project ${p}
            rename_project ${p} "deleted-$p-$(date +%s)" # zz so it appears at the bottom of the list
        fi
        date
        echo '-----------------------------------------------------'
    done
}

# this is for missed directories
echo '-----------------------------------------------------'
date
init
date
echo '-----------------------------------------------------'
watch_directory

#gitlab_api GET "/projects/$(get_project_id deleted-deleted-deleted-deleted-deleted-new-project)"

#delete_removed_directories
#delete_project "deleted-test"

#delete_project test
#for d in $(ls -da $dir*); do
#    delete_project $(get_name_from_path ${d})
#done
#create_and_commit test testing

#delete_project $1