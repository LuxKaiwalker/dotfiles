# Aliases
alias ls 'ls --color=auto'
alias grep 'grep --color=auto'

# Flutter and Dart
set -x FLUTTER_HOME /home/vincent/flutter
set -x PATH $FLUTTER_HOME/bin $FLUTTER_HOME/bin/cache/dart-sdk/bin $PATH

# Java
set -x JAVA_HOME /usr/lib/jvm/java-17-openjdk
set -x PATH $JAVA_HOME/bin $PATH

# NVM
set -x NVM_DIR $HOME/.nvm
if test -s $NVM_DIR/nvm.sh
    bass source $NVM_DIR/nvm.sh
end

# ghcup
if test -f /home/vincent/.ghcup/env
    bass source /home/vincent/.ghcup/env
end

# Local scripts
set -x PATH $HOME/bin $HOME/.local/bin $PATH
