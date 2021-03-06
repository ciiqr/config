#!/usr/bin/env bash

set -eo pipefail
shopt -s nullglob

backup::backup()
{
    # parse args
    backup::_parse_args_backup "$@"

    # setup failure trigger
    failure()
    {
        # notify failure
        backup::_send_notification 'Backup' 'Failed!' -t 0
    }
    trap failure ERR

    # get host
    declare host="$(backup::_get_hostname)"
    backup::_ensure_hostname "$host"

    # notify start
    backup::_send_notification 'Backup' 'Started'

    # check repo
    if [[ "$check" == 'true' ]]; then
        backup::_step 'checking repo'
        backup::check -q
    fi

    # prepare dynamic info
    backup::_step 'prepare dynamic info'
    backup::_prepare_dynamic_info

    # prepare paths to backup
    backup::_step 'prepare backup paths'
    declare -a paths=()
    backup::_prepare_backup_paths

    # print backup paths
    for backup_path in "${paths[@]}"; do
        echo "- ${backup_path}"
    done

    # actually backup data
    backup::_step 'backing up data'
    # TODO: on windows, restic is saving backups with relative paths, this needs to be fixed
    backup::restic backup --exclude-file ~/.restic/exclude "${paths[@]}"

    # prune
    if [[ "$prune" == 'true' ]]; then
        backup::_step 'pruning old snapshots'
        backup::prune "$host"
    elif [[ "$prune_all" == 'true' ]]; then
        backup::_step 'pruning old snapshots for all hosts'
        backup::prune_all "$host"
    fi

    # re-checking
    if [[ "$check" == 'true' ]]; then
        backup::_step 're-checking repo'
        backup::check -q
    fi

    # notify finish
    backup::_send_notification 'Backup' 'Finished'
}

backup::_parse_args_backup()
{
    dry_run=''
    prune='false'
    prune_all='false'
    check='true'
    notify='true'

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run='echo $'
            ;;
            --prune)
                prune='true'
            ;;
            --prune-all)
                prune_all='true'
            ;;
            --no-check)
                check='false'
            ;;
            --no-notify)
                notify='false'
            ;;
            *)
                echo "$0: Unrecognized option $1" 1>&2
                return 1
            ;;
        esac
        shift
    done
}

backup::_send_notification()
{
    if [[ "$notify" == 'true' ]]; then
        ~/.scripts/notification.sh send "$@"
    fi
}

backup::prune()
{
    # get host
    declare host="${1:-$(backup::_get_hostname)}"
    backup::_ensure_hostname "$host"

    # prune
    backup::restic forget --host "$host" --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 12
}

backup::prune_all()
{
    # prune all hosts
    backup::restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 12
}

backup::check()
{
    backup::restic check "$@"
}

backup::mount()
{
    if ~/.scripts/system.sh is-osx; then
        declare backups_directory='/Volumes/backups'
    else
        declare backups_directory='/mnt/backups'
    fi

    # ensure backups directory exists
    if [[ ! -d "$backups_directory" ]]; then
        sudo mkdir -p "$backups_directory"
    fi

    # mount
    backup::restic mount --no-default-permissions --allow-other "$@" "$backups_directory"
}

backup::restic()
{
    $dry_run sudo -E restic "$@"
}

backup::_step()
{
    echo '==>' "$@"
}

backup::_get_hostname()
{
    echo "${HOST:-$HOSTNAME}"
}

backup::_ensure_hostname()
{
    if [[ -z "$1" ]]; then
        echo 'Could not determine hostname'
        exit 1
    fi
}

backup::_append_existent_paths()
{
    declare potential_path
    for potential_path in "$@"; do
        if [[ -e "$potential_path" ]]; then
            paths+=("$potential_path")
        fi
    done
}

backup::_get_info_directory()
{
    # TODO: should I just change all to ~/.info ?
    if ~/.scripts/system.sh is-windows; then
        echo '/c/info'
    elif ~/.scripts/system.sh is-osx; then
        echo "${HOME}/.info"
    else
        echo '/info'
    fi
}

backup::_prepare_dynamic_info()
{
    declare info_directory="$(backup::_get_info_directory)"

    # ensure info dir exists
    if [[ ! -d "$info_directory" ]]; then
        sudo mkdir "$info_directory"
        sudo chmod a+w "$info_directory"
    fi

    # packages
    declare packages_file="${info_directory}/packages"
    declare packages_explicit_file="${info_directory}/packages-explicit"
    declare packages_explicit_versions_file="${info_directory}/packages-explicit-versions"

    if ~/.scripts/system.sh is-void-linux; then
        xbps-query -l | awk '{ print $2 }' | xargs -n1 xbps-uhelper getpkgname | sudo tee "$packages_file" >/dev/null
        xbps-query -m | xargs -n1 xbps-uhelper getpkgname | sudo tee "$packages_explicit_file" >/dev/null
        xbps-query -m | sudo tee "$packages_explicit_versions_file" >/dev/null
    elif ~/.scripts/system.sh is-osx; then
        brew ls | sudo tee "$packages_file" >/dev/null
        brew leaves | sudo tee "$packages_explicit_file" >/dev/null
        brew ls --versions $(brew leaves) | sudo tee "$packages_explicit_versions_file" >/dev/null
    elif ~/.scripts/system.sh is-windows; then
        choco.exe list -l --id-only | sudo tee "$packages_file" >/dev/null
    fi

    # services
    declare services_enabled_file="${info_directory}/services-enabled"

    if ~/.scripts/system.sh is-void-linux; then
        ls -l /var/service/ | sudo tee "$services_enabled_file" >/dev/null
    fi

    # external
    if [[ -d ~/External ]]; then
        declare external_repos="${info_directory}/external-repos"

        # write all external repo urls
        echo -n '' | sudo tee "$external_repos" >/dev/null
        for git_path in ~/External/*/.git ~/External/*/*/.git; do
            git -C "${git_path%/.git}" remote get-url origin | sudo tee -a "$external_repos" >/dev/null
        done
    fi

    # per-host
    if [[ "$host" == 'server-data' ]]; then
        # list of unsynced media
        find /mnt/data/Movies /mnt/data/Shows /mnt/data/Downloads > "${info_directory}/unsynced.txt"

        # Github repos
        ~/.scripts/github-clone-all.sh user ciiqr /mnt/data/William/Vault/Github/ciiqr
        ~/.scripts/github-clone-all.sh organization pentible /mnt/data/William/Vault/Github/pentible
    fi
}

backup::_prepare_backup_paths()
{
    # per-platform
    if ~/.scripts/system.sh is-linux; then
        paths+=(/etc)
    elif ~/.scripts/system.sh is-osx; then
        paths+=(/private/etc)
    elif ~/.scripts/system.sh is-windows; then
        paths+=(~/Documents)
        backup::_append_existent_paths \
            '/c/Program Files (x86)/World of Warcraft/_retail_'/{Interface/Addons,WTF} \
            ~/AppData/Roaming/.minecraft/saves
    fi

    # base
    backup::_append_existent_paths ~/{.histfile,.bash_history,.python_history,.pythonhist,.macro/}
    # synced
    backup::_append_existent_paths ~/{Docs,Projects,Inbox,Screenshots,.wallpapers,.archive}

    # per-host
    if [[ "$host" == 'server-data' ]]; then
        paths+=(
            /mnt/data/William/Sync
            /mnt/data/William/Vault
            /mnt/data/Paige
            /mnt/data/UMusic
            /mnt/data/Music
        )
    fi

    # info
    paths+=("$(backup::_get_info_directory)")
}

main()
{
    # env
    . ~/.restic/env

    case "$1" in
        backup)
            backup::backup "${@:2}"
            ;;
        prune)
            backup::prune
            ;;
        prune-all)
            backup::prune_all
            ;;
        check)
            backup::check "${@:2}"
            ;;
        mount)
            backup::mount "${@:2}"
            ;;
        restic)
            backup::restic "${@:2}"
            ;;
        *)
            echo 'usage: '
            echo '  ~/.scripts/backup.sh backup [--prune] [--prune-all] [--dry-run] [--no-check] [--no-notify]'
            echo '  ~/.scripts/backup.sh prune'
            echo '  ~/.scripts/backup.sh prune-all'
            echo '  ~/.scripts/backup.sh restic <command>'
            echo '  ~/.scripts/backup.sh restic ls -l latest'
            echo '  ~/.scripts/backup.sh check'
            echo '  ~/.scripts/backup.sh mount'
            ;;
    esac
}

main "$@"
