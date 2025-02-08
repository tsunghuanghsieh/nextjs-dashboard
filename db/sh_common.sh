MSG_ERROR_PREFIX="\033[41m\033[30mERROR:\033[0m"    # \033[41m red background, \033[30m black text
MSG_WARNING_PREFIX="\033[103m\033[30mWARNING:\033[0m" # \033[103m yellow background, \033[30m black text

#
# print message in red background
#
formatRed() {
    echo "\033[41m\033[30m$1\033[0m"
}

#
# print message in yellow background
#
formatYellow() {
    echo "\033[103m\033[30m$1\033[0m"
}

#
# print error message
#
showError() {
    echo -e $MSG_ERROR_PREFIX 1>&2
    echo -e $MSG_ERROR_PREFIX $1... 1>&2
    echo -e $MSG_ERROR_PREFIX 1>&2
    exit 1
}

#
# print warning message
#
showWarning() {
    echo -e $MSG_WARNING_PREFIX 1>&2
    echo -e $MSG_WARNING_PREFIX $1... 1>&2
    echo -e $MSG_WARNING_PREFIX 1>&2
    exit 1
}

