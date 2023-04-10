check_if_repository_exists() {
	xrepo list-repo | grep -q "$1"
}

check_if_dependency_exists() {
	xrepo scan "$1" | grep -q "$1"
}

prompt_user_to_select() {
  PACKAGES="$1"

	# Iterate over each line of packages
	echo "$PACKAGES" | while read -r PACKAGE; do
		# Before the first ':' is the package name and version
		PACKAGE_NAME=$(echo "$PACKAGE" | cut -d ':' -f 1)
		# After the first ':' is the package description
		PACKAGE_DESCRIPTION=$(echo "$PACKAGE" | cut -d ':' -f 2)

		# The package name and version is separated by the last '-'
		PACKAGE_VERSION=$(echo "$PACKAGE_NAME" | rev | cut -d '-' -f 1 | rev)
		PACKAGE_NAME=${PACKAGE_NAME//-$PACKAGE_VERSION/}

		# Sanitize the strings
		PACKAGE_NAME=$(sanitize_string "$(remove_all_spaces "$PACKAGE_NAME")")
		PACKAGE_VERSION=$(sanitize_string "$PACKAGE_VERSION")
		PACKAGE_DESCRIPTION=$(sanitize_string "$PACKAGE_DESCRIPTION")

		# Print the package name, version and description
		echo "$PACKAGE_NAME-$PACKAGE_VERSION: $PACKAGE_DESCRIPTION"
	done | fzf --prompt="Which dependency correspond to your desired dependency: ${DEPENDENCY}" --reverse --height=50% --layout=reverse --border --ansi --multi | while read -r PACKAGE; do
		# Get the package name and version from the selected package
		PACKAGE_NAME=$(echo "$PACKAGE" | cut -d '-' -f 1)
		PACKAGE_VERSION=$(echo "$PACKAGE" | cut -d '-' -f 2 | cut -d ':' -f 1)

		# Install the package
		xrepo install "$PACKAGE_NAME" "$PACKAGE_VERSION"
	done
}

