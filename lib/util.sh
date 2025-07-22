_add_if_missing_or_empty() {
    # Usage: add_if_missing_or_empty "file" "VARNAME" "new_value"
    local file="$1"
    local varname="$2"
    local new_value="$3"

    # Escape regex special characters in varname
    local escaped_varname=$(printf '%s\n' "$varname" | sed -e 's/[][\/.^$*]/\\&/g')

    # Create regex patterns
    local empty_regex="^[[:space:]]*${escaped_varname}[[:space:]]*=[[:space:]]*(\"\"|''|)[[:space:]]*$"
    local any_value_regex="^[[:space:]]*${escaped_varname}[[:space:]]*="

    # Check if variable exists with any value
    if grep -qE "$any_value_regex" "$file"; then
        # Check if empty/unset
        if grep -qE "$empty_regex" "$file"; then
            # Update first empty occurrence (handles spaces around =)
            sed -i -E "0,/${empty_regex}/s/${empty_regex}/${varname}=${new_value}/" "$file"
            echo "Updated empty ${varname} with new value" >&2
        else
            echo "Preserving existing non-empty value for ${varname}" >&2
            return 0
        fi
    else
        # Add new entry (with newline if file doesn't end with one)
        [ -s "$file" ] && [ -z "$(tail -c 1 "$file")" ] || echo >> "$file"
        echo "${varname}=${new_value}" >> "$file"
        echo "Added new ${varname} entry" >&2
    fi
}

_apt-get-install() {
    DPKG=`dpkg -l`
    packages=("$@")
    for file in "${packages[@]}"; do
        if ! echo "$DPKG" | grep -q "^ii *$file"; then
            DEBIAN_FRONTEND=noninteractive apt-get install -y $@
            break
        fi
    done
}

_apt-get-update() {
    # Usage: apt_update_if_needed [max_age_hours] (default: 24)
    local max_age_hours=${1:-24}
    local last_update
    local current_time
    local time_diff

    # Get last update time (in seconds since epoch)
    last_update=$(stat -c %Y /var/lib/apt/periodic/update-success-stamp 2>/dev/null || \
                  stat -c %Y /var/lib/apt/lists/ 2>/dev/null || \
                  echo 0)

    current_time=$(date +%s)
    time_diff=$(( (current_time - last_update) / 3600 ))  # Convert to hours

    if [ "$time_diff" -ge "$max_age_hours" ]; then
        echo "APT last updated ${time_diff} hours ago. Running apt-get update..."
        apt-get update -qq
        touch /var/lib/apt/periodic/update-success-stamp
        echo "APT package lists updated"
    fi
}

# Check that a variable isn't empty. Do this after loading .env
_check_exists() {
    [ -z "${!1}" ] && { echo "Error: $1 isn't specified in .env" >&2; exit 1; }
}

_create_system_user() {

    # Create a system user for running an app

    _need_root

    local username="$1"
    local homedir="/var/lib/$username"

    # Check if username is provided
    if [[ -z "$username" ]]; then
        echo "Usage: _create_system_user <username>"
        return 1
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        return 0
    fi

    # Create the user:
    # -r: system user (no password, non-login)
    # -s /usr/sbin/nologin: non-login shell
    # -d: home directory
    # -m: create home directory
    useradd -r -m -d "$homedir" -s /usr/sbin/nologin "$username"

    # Set permissions for the home directory
    chown -R "$username":"$username" "$homedir"

    echo "User '$username' created with home '$homedir' and non-login shell."
}

_export_bw_fields() {
    # Export fields from Bitwarden.  Must set VAULTID environment variable first.
    #
    # Bitwarden CLI must be logged in and unlocked.
    #
    # Bitwarden contains an item with fields.  This routine gets the fields and exports them as environment variables.

     while read -r line; do
        eval "$line"
    done < <(
        perl -MJSON -e '
            my $item = decode_json(`bw get item "$ENV{VAULTID}"`);
            foreach my $field (@{$item->{fields}}) {
                my $name = $field->{name};
                my $value = $field->{value};
                $value =~ s/"/\\"/g;  # Escape any double quotes
                print "export $name=\"$value\"\n";
            }
        '
    )
}

_get_env_value() {
    # Usage: get_env_value "VAR_NAME"
    local var_name="$1"
    local env_file=".env"

    if [ ! -f "$env_file" ]; then
	cp env.example .env
    fi

    # Read the line, trim whitespace, handle quoted values and comments
    local value
    if value=$(grep -E "^[[:space:]]*${var_name}[[:space:]]*=" "$env_file" | \
               tail -1 | \
               cut -d '=' -f2- | \
               sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^["'\'']//' -e 's/["'\'']$//'); then
        echo "$value"
    else
        echo "Error: Variable $var_name not found in $env_file" >&2
        return 1
    fi
}

_get_bw_fields() {
    # Fetch fields from Bitwarden.  Must set VAULTID environment variable first.
    #
    # Bitwarden CLI must be logged in and unlocked.
    #
    # Bitwarden contains an item with fields.  This routine gets the fields and sets $fields to them.

    fields=$(perl -MJSON -e '
	my $item = decode_json(`bw get item "$ENV{VAULTID}"`);
	my %fields = map { $_->{name} => $_->{value} } @{$item->{fields}};
	print encode_json(\%fields);
    ')
}

_git-clone() {
   # clone or update git repo
   # 2 params: repo url and dest dir
   mkdir -p "$2"
   if ! [ -d "$2/.git" ]; then
      git clone "$1" "$2"
   else
      pushd "$2" > /dev/null
      git fetch
      git rebase origin
      popd > /dev/null
   fi
}

_load_env() {
    # Load environment variables from .env file

    if [ -f .env ]; then
	set -a # automatically export all variables
	source .env
	set +a # stop automatically exporting
    else
        cp env.example .env
    fi
}

_podman-create-secret() {
    # Create a podman secret if it doesn't already exist

    # Example usage:
    # _podman_create_secret "neems-demo" "db_password" "mysecurepassword123"

    _need_root

  local user="$1"
  local secret_name="$2"
  local secret_value="$3"

  # Validate inputs
  if [[ -z "$user" || -z "$secret_name" || -z "$secret_value" ]]; then
    echo "Error: Missing arguments. Usage: _podman_create_secret <user> <secret_name> <secret_value>"
    return 1
  fi

  # Check if secret already exists
  if sudo -u "$user" podman secret inspect "$secret_name" &>/dev/null; then
    echo "Secret '$secret_name' already exists for user '$user'. Skipping creation."
    return 0
  fi

  # Create the secret
  echo "Creating secret '$secret_name' for user '$user'..."
  echo -n "$secret_value" | sudo -u "$user" podman secret create "$secret_name" -

  # Verify creation
  if sudo -u "$user" podman secret inspect "$secret_name" &>/dev/null; then
    echo "Successfully created secret '$secret_name'"
    return 0
  else
    echo "Failed to create secret '$secret_name'"
    return 1
  fi
}

_podman-create-user() {

    # Create a system user for running podman containers on the app server

    _need_root

    local username="$1"

    _system_create_user $username

    # Enable lingering for our new user so that it can run podman
    loginctl enable-linger $(id -u ${username})

    # Create subuid and subgid ranges for the user so that it can run podman
    usermod --add-subuids 100000-165535 --add-subgids 100000-165535 ${username}
    sudo -u "${username}" podman system migrate

    echo "User '$username' is now podman-enabled."
}

_need_root() {
    [ "$(id -u)" -eq 0 ] || { echo "This script must be run as root" >&2; exit 1; }
}

_replace_or_add_line() {
    # Usage: _replace_or_add_line "file" "pattern" "new_line"
    local file="$1"
    local pattern="$2"
    local new_line="$3"

    # Process the file
    if grep -q "$pattern" "$file"; then
        # Special handling for ^ start anchor
        if [[ "$pattern" == ^* ]]; then
            # Remove ^ for the replacement pattern
            local sed_pattern="${pattern#^}"
            sed -i -E "0,/^${sed_pattern}/s|^${sed_pattern}.*|$new_line|" "$file"
        else
            # Normal replacement
            sed -i -E "s|${pattern}.*|$new_line|" "$file"
        fi
    else
        # Append new line
        echo "$new_line" >> "$file"
    fi

}

fields() {
    ## Get our environment variables from Bitwarden
    #
    # Must first do something like: export VAULTID="cda8f639-96d1-463d-ae80-3923f0e05b9a"
    _get_fields
    echo "$fields"
}

push() {
    # Usage: push hostname

    cd ${BASEDIR}

    # Set destination target.  Either we use the root account on the
    # remote server or, if $1 is localhost, we just use
    # /opt/${BASEDIR} as our destination.

    # If $1 is 'localhost', just use /opt/${BASEDIR} as the destination.
    local dirname=$(basename "${BASEDIR}")

    local dest
    local target
    if [[ "$1" == "localhost" ]]; then
	_need_root
        dest="/opt/${dirname}/"
        target="$dest"
    else
        dest="$1:/opt/${dirname}/"
        target="root@$dest"
    fi

# Build rsync command
    local rsync_cmd=("rsync" "-rLvz" "--progress")

    # Add standard excludes
    rsync_cmd+=(
        "--exclude=.claude/"
        "--exclude=.DS_Store"
        "--exclude=.git/"
        "--exclude=.gitignore"
        "--exclude=.gitmodules"
        "--exclude=.gitattributes"
        "--exclude=.push-exclude"
        "--exclude=*.swp"
    )

    # Add excludes from .push-exclude file if it exists
    if [[ -f ".push-exclude" ]]; then
        rsync_cmd+=("--exclude-from=.push-exclude")
    fi

    # Add source and destination
    rsync_cmd+=("./" "${target}")

    echo "Copying local files to $dest"
    echo
    # Print the command (with proper quoting for debugging)
    printf "%q " "${rsync_cmd[@]}"
    echo
    "${rsync_cmd[@]}"
}
