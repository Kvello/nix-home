if status is-interactive
    bass source ~/.fishrc
    set fish_greeting
    # Commands to run in interactive sessions can go here
end
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
set -gx MAMBA_EXE "/nix/store/xd9gda38gf6j4is520ihx6r0vfwhsy8z-mamba-cpp-2.1.1/bin/mamba"
set -gx MAMBA_ROOT_PREFIX "/home/markus/.local/share/mamba"
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <<<
