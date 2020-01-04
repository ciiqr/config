#!/usr/bin/env bash

set -eo pipefail

backup::backup()
{
    # parse args
    backup::_parse_args_backup "$@"

    # setup failure trigger
    failure()
    {
        # notify failure
        # TODO: this is dumb and only works because we're not using additional params in the osx send_notification script
        send_notification 'Backup' 'Failed!' -t 0
    }
    trap failure ERR

    # get host
    declare host="${1:-$(backup::_get_hostname)}"
    backup::_ensure_hostname "$host"

    # notify start
    send_notification 'Backup' 'Started'

    # check repo
    backup::_step 'checking repo'
    $dry_run restic check -q

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
    $dry_run sudo -E restic backup --exclude-file ~/.restic/exclude "${paths[@]}"

    # prune
    if [[ "$prune" == 'true' ]]; then
        backup::_step 'pruning old snapshots'
        backup::prune "$host"
    fi

    # re-checking
    backup::_step 're-checking repo'
    $dry_run restic check -q

    # notify finish
    send_notification 'Backup' 'Finished'
}

backup::_parse_args_backup()
{
    dry_run=''
    prune='false'

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run='echo $'
            ;;
            --prune)
                prune='true'
            ;;
            *)
                echo "$0: Unrecognized option $1" 1>&2
                return 1
            ;;
        esac
        shift
    done
}

backup::prune()
{
    # get host
    declare host="${1:-$(backup::_get_hostname)}"
    backup::_ensure_hostname "$host"

    # prune
    backup::restic forget --host "$host" --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 12
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
    backup::restic mount --allow-other "$@" "$backups_directory"
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
    if ~/.scripts/system.sh is-windows; then
        echo '/mnt/c/info'
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

        # TODO: figure out if we can limit to explicitly/manually installed packages
        # choco.exe list -l

        # TODO: also wsl ubuntu's apt?
    fi

    # services
    declare services_enabled_file="${info_directory}/services-enabled"

    if ~/.scripts/system.sh is-void-linux; then
        ls -l /var/service/ | sudo tee "$services_enabled_file" >/dev/null
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
        backup::_append_existent_paths '/mnt/c/Program Files (x86)/World of Warcraft/_'{retail,classic}'_'/{Interface/Addons,WTF}
    fi

    # base
    backup::_append_existent_paths ~/{.histfile,.bash_history,.python_history,.pythonhist,.macro/}
    # synced
    backup::_append_existent_paths ~/{Dropbox,Docs,Projects,Inbox,Screenshots,.wallpapers}
    # info
    paths+=("$(backup::_get_info_directory)")

    # per-host
    if [[ "$host" == 'server-data' ]]; then
        :
        # TODO:
        # - music/etc on server
        # - : media filepath list
        #     find /srv/media -type f > /info/...
        # - wherever we store sync data
    fi
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
        mount)
            backup::mount "${@:2}"
            ;;
        restic)
            backup::restic "${@:2}"
            ;;
        *)
            echo 'usage: '
            echo '  ~/.scripts/backup.sh backup [--prune] [--dry-run]'
            echo '  ~/.scripts/backup.sh prune'
            echo '  ~/.scripts/backup.sh restic <command>'
            echo '  ~/.scripts/backup.sh restic ls -l latest'
            echo '  ~/.scripts/backup.sh mount'
            echo '    # --no-default-permissions: to allow my user to access root files in the backup'
            ;;
    esac
}

main "$@"

# TODO: consider scheduling/nice
# 0 4 * * * ionice -c2 -n7 nice -n19 bash /root/backup.sh > /var/log/backup.log 2>&1

# TODO: anacron on linux frontend machines
# TODO: cron on linux server machines
# TODO: launchd on osx: https://stackoverflow.com/questions/132955/how-do-i-set-a-task-to-run-every-so-often
# TODO: task scheduler on windows (will need to run with bash)
