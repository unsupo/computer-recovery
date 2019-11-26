#!/usr/bin/env bash

# if computer-recovery/mac/git changes at all then run the git-manager.sh script
# if new directory is created run: git config --get remote.origin.url and add it to either github-links.txt or gitwork-links.txt depending on which folder

commit_project(){
    return
}

create_dir_watcher(){
    [[ -z $1 || ! -d $1 ]] && { echo "must pass a valid directory to create_dir_watcher method instead passed: $1"; return; }
    dir_name=$1
    ${fswatch} -uEe '.*/\.git' --format '%t|%p|%f' -l5 ~/${dir_name} | while read event; do # Ee '.*/$dir_name/.*/' # exclude # -l5 is batch every 5 seconds # latency
        echo "-----------------------------------------------------"
        date
        IFS='|' read -ra ADDR <<< "$event"
        dt=${ADDR[0]} # date
        path=${ADDR[1]} # path of changed file
        es=${ADDR[2]} # specific event like IsFile IsDir Created Deleted ect
        IFS=' ' read -ra events <<< "$es" # get each specific event separated by the space
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
        last_event=${events[${#events[@]}-1]}
        if [[ "$last_event" == "IsFile" ]]; then
            echo "commit_project \"$dir$pd\" ${event}"
            commit_project "$dir$pd" "${event}"
            date
            echo "-----------------------------------------------------"
            continue
        fi
        if [[ ${p} =~ ^.*/\$dir_name/.*/$ ]]; then
            echo "continuing because this is a subdirectory $p"
            date
            echo "-----------------------------------------------------"
            continue
        fi
        if [[ "${events[0]}" == "Created" && "$last_event" == "IsDir" ]]; then
            echo "create project ${p}"
            create_and_commit ${p} $(get_name_from_path ${p})
        fi
        # TODO deleted directories should i just delete it from gitlab or rename it to deleted?
        if [[ "${events[0]}" == "Deleted" && "$last_event" == "IsDir" ]]; then
            echo "deleted project ${p}, renaming to deleted-$p"
            rename_project ${p} "deleted-$p-$(date +%s)" # zz so it appears at the bottom of the list
        fi
        date
        echo "-----------------------------------------------------"
    done
}