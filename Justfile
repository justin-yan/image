@default:
    just --list

massupdate:
    #!/usr/bin/env bash
    git stash clear
    find . -name '.cruft.json' | xargs -I {} dirname {} | xargs -I {} sh -c 'cd {}; cruft update -y && git stash'
    while git stash pop; do :; done

render:
    cruft create git@github.com:justin-yan/templates-cruft --directory=image-public/docker-standard


######
## CICD Integrations
######

@cicd-pr:
    just differential_projects pr
    cat /tmp/just_differential_projects | xargs -I {} just {}/cicd-pr

@cicd-register:
    just differential_projects register
    cat /tmp/just_differential_projects | xargs -I {} just {}/cicd-register

pr_file_diff:
    #!/usr/bin/env bash
    git diff --name-only origin/${GITHUB_BASE_REF} HEAD | grep -E '^[^./][^/]*/' > /tmp/just_pr_file_diff

register_file_diff:
    #!/usr/bin/env bash
    git diff --name-only HEAD^1 HEAD -G"^VERSION:=" "*/Justfile" > /tmp/just_register_file_diff

differential_projects OPERATION:
    #!/usr/bin/env bash
    project_folders=()
    while IFS= read -r project; do
        project_folders+=("${project#./}")
    done < <(find . -mindepth 2 -maxdepth 2 -name 'Justfile' -not -path './.git/*' -not -path './.github/*' -printf '%h\n')

    just {{OPERATION}}_file_diff
    readarray -t modified_files < /tmp/just_{{OPERATION}}_file_diff

    modified_projects=()
    for project in "${project_folders[@]}"; do
        for modified_file in "${modified_files[@]}"; do
            if [[ "$modified_file" == "$project/"* ]]; then
                modified_projects+=("$project")
                break
            fi
        done
    done

    printf "%s\n" "${modified_projects[@]}" > /tmp/just_differential_projects
