# Disable standard file completion by default
complete -c stalker-gamma -f

# Helper functions to detect what state the command line is in
function __fish_stalker_gamma_needs_command
    set cmd (commandline -opc)
    if test (count $cmd) -eq 1
        return 0
    end
    return 1
end

function __fish_stalker_gamma_using_command
    set -l cmd (commandline -opc)
    if test (count $cmd) -gt 1
        if string match -q "$argv*" (string join ' ' $cmd[2..-1])
            return 0
        end
    end
    return 1
end

# -----------------------------------------------------------------------------
# Global Flags
# -----------------------------------------------------------------------------
complete -c stalker-gamma -s h -l help -d 'Show help information'
complete -c stalker-gamma -l version -d 'Show version information'

# -----------------------------------------------------------------------------
# Top-Level Commands
# -----------------------------------------------------------------------------
complete -c stalker-gamma -n __fish_stalker_gamma_needs_command -a anomaly -d 'Manage Stalker Anomaly'
complete -c stalker-gamma -n __fish_stalker_gamma_needs_command -a config -d 'Manage profiles and settings'
complete -c stalker-gamma -n __fish_stalker_gamma_needs_command -a debug -d 'Debug utilities'
complete -c stalker-gamma -n __fish_stalker_gamma_needs_command -a full-install -d 'Install/update Anomaly and all GAMMA addons (~150GB)'
complete -c stalker-gamma -n __fish_stalker_gamma_needs_command -a gog -d 'GOG-specific fixes'
complete -c stalker-gamma -n __fish_stalker_gamma_needs_command -a mo2 -d 'Mod Organizer 2 configurations'
complete -c stalker-gamma -n __fish_stalker_gamma_needs_command -a update -d 'Check or apply updates'

# -----------------------------------------------------------------------------
# Subcommands: anomaly
# -----------------------------------------------------------------------------
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command anomaly' -a check -d 'Verifies the integrity of Stalker Anomaly'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command anomaly' -a delete-reshade -d 'Deletes all ReShade-related files from the Anomaly bin directory'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command anomaly' -a install -d 'Installs Stalker Anomaly'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command anomaly' -a purge-shader-cache -d 'Deletes the shader cache directory for the active Anomaly profile'

# -----------------------------------------------------------------------------
# Subcommands: config
# -----------------------------------------------------------------------------
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command config' -a create -d 'Create settings file'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command config' -a delete -d 'Delete a profile'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command config' -a info -d 'Print the currently active profile settings'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command config' -a list -d 'List profiles'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command config' -a set -d 'Edit a setting in the currently active profile'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command config' -a use -d 'Set a profile as active'

# -----------------------------------------------------------------------------
# Subcommands: debug
# -----------------------------------------------------------------------------
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command debug' -a hash-install -d 'Hashes installation folders and creates a compressed archive'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command debug' -a logs -d 'Open the logs folder'

# -----------------------------------------------------------------------------
# Subcommands: gog
# -----------------------------------------------------------------------------
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command gog' -a fix-install -d 'Fix the GOG installation paths in ModOrganizer.ini'

# -----------------------------------------------------------------------------
# Subcommands: update
# -----------------------------------------------------------------------------
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command update' -a apply -d 'Apply any updates'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command update' -a check -d 'Check for updates'

# -----------------------------------------------------------------------------
# Subcommands: mo2 (Nested Level 2 & 3)
# -----------------------------------------------------------------------------
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2' -a config -d 'Manage ModOrganizer.ini configuration'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2' -a mod -d 'Modify active or inactive mods'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2' -a profile -d 'Delete or view specific profile files'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2' -a profiles -d 'List all profiles'

# mo2 config ...
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 config' -a get -d 'Get fields from ModOrganizer.ini'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 config' -a set -d 'Set fields in ModOrganizer.ini'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 config get' -a selected-profile -d 'Retrieves the selected profile information'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 config set' -a selected-profile -d 'Updates the selected profile'

# mo2 mod ...
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 mod' -a delete -d 'Deletes a specified mod in the provided profile'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 mod' -a disable -d 'Disables a specified mod in the given profile'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 mod' -a enable -d 'Enables a specified mod within a given profile'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 mod' -a status -d 'Show mod status info'

# mo2 profile / profiles ...
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 profile' -a delete -d 'Deletes a specified profile from a Gamma installation'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 profile list' -a mods -d 'Lists all mods in a profile'
complete -c stalker-gamma -n '__fish_stalker_gamma_using_command mo2 profiles' -a list -d 'Lists all profiles in a gamma installation'
