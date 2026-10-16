# Aliases
alias ls 'ls --color=auto'
alias grep 'grep --color=auto'

# Flutter and Dart. Guarded because the SDK is not currently installed: an
# unguarded `set -x FLUTTER_HOME` exports a path to nothing, which tools then
# trust and fail on confusingly.
set -l flutter_home /home/vincent/flutter
if test -d $flutter_home
    set -x FLUTTER_HOME $flutter_home
    fish_add_path -g $flutter_home/bin $flutter_home/bin/cache/dart-sdk/bin
end

# Java
set -l java_home /usr/lib/jvm/java-17-openjdk
if test -d $java_home
    set -x JAVA_HOME $java_home
    fish_add_path -g $java_home/bin
end

# NVM
#
# Sourcing nvm.sh here cost ~250ms of every shell's startup: `bass` shells out
# to mktemp + python3 + bash to translate 4.4k lines of nvm into fish, and all
# that work only ever produced a PATH entry.
#
# So put the default version's bin on PATH directly, and defer the real nvm to
# a function that loads it on first use. `nvm use 20` still works; it just pays
# the 250ms once, in the shell that asked for it, instead of in all of them.
set -x NVM_DIR $HOME/.nvm
if test -d $NVM_DIR
    # Resolve the version `nvm` would have picked for a fresh shell: the
    # `default` alias, falling back to the newest installed version.
    set -l nvm_default
    if test -f $NVM_DIR/alias/default
        set nvm_default (string trim <$NVM_DIR/alias/default)
    end
    # The alias may name a partial version ("22"), a full one ("v22.14.0") or a
    # symbolic name ("node"/"stable"); match it as a prefix either way.
    set -l nvm_bin $NVM_DIR/versions/node/v(string replace -r '^v' '' -- $nvm_default)*/bin
    set -l nvm_match (path filter -d $nvm_bin 2>/dev/null | sort -V)
    if test -z "$nvm_match"
        set nvm_match (path filter -d $NVM_DIR/versions/node/*/bin | sort -V)
    end
    if test -n "$nvm_match"
        fish_add_path -g $nvm_match[-1]
    end

    # nvm is a shell function, not a binary, so it cannot outlive the bash
    # process bass runs it in -- the wrapper has to stay and re-source per
    # call. `--no-use` skips nvm's own default-version activation, which this
    # file already did above; bass then carries the resulting PATH back here,
    # so `nvm use 20` still changes the version for this shell.
    function nvm --description 'Run nvm in bash, importing its PATH changes'
        bass source $NVM_DIR/nvm.sh --no-use ';' nvm $argv
    end
end

# Local scripts
fish_add_path -g $HOME/bin $HOME/.local/bin
