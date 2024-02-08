#!/bin/bash
set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "execute command" bash -c "flutter doctor"

# Report result
reportResults