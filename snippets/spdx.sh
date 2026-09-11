#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#jq -c bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

snippet_file="$SCRIPT_DIR/spdx.json"
licenses_json="$(mktemp spdx-licenses.XXXX.json)"

curl -o "$licenses_json" https://spdx.org/licenses/licenses.json

echo "$snippet_file"
cat "$licenses_json"

readarray -t licenses < <(jq -r '.licenses[].licenseId' "$licenses_json")

license_choices=$(
	IFS=,
	echo "${licenses[*]}"
)

echo "
{
  \"SPDX-License-Identifier\": {
    \"prefix\": [\"spdx\"],
    \"body\": [\"\$LINE_COMMENT SPDX-License-Identifier: \${1|$license_choices|} \$0\"],
    \"description\": \"Add a SPDX-License-Identifier for the file\"
  }
}
" >"$snippet_file"
