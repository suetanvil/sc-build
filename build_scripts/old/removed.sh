


function find_projects {
    cd workdir

    # Search the list of release tags for one we can build.
    git -C supercollider tag --list | \
        grep -P '^Version-\d+.\d+\.\d+\s*$' | \
        while read tag; do
            local tarball=$(installer_name $tag)

            # Skip any tags in the known list
            grep -q "$tag" ../support/tags-to-skip.txt && continue

            # For now, only build this one.
            [ "$tag" = "Version-3.11.2" ] || continue
            
            echo "Target: $tag"
            touch tags/$tag
        done

    cd ..
}

