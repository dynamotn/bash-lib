#!/usr/bin/env bash
# @file logging.sh
# @brief Utilities for logging to stdout/stderr
# @description
#   This module contains functions to log messages to stdout/stderr.
: "${DYBATPHO_DIR:?DYBATPHO_DIR must be set. Please source dybatpho/init.sh before other scripts from dybatpho.}"

LOG_LEVEL=$(dybatpho::lower "${LOG_LEVEL:-info}")
export LOG_LEVEL

#######################################
# @description Verify log level from input.
# @arg $1 string String of log level
# @exitcode 0 If is valid log level
# @exitcode 1 If invalid
#######################################
function __verify_log_level {
  local level="${1}"
  level=$(dybatpho::lower "$level")
  if [[ ${level} =~ trace|debug|info|warn|error|fatal ]]; then
    return 0
  else
    echo "${level} is not a valid LOG_LEVEL, it should be trace|debug|info|warn|error|fatal"
    return 1
  fi
}

#######################################
# @description Log a message to stdout/stderr with color and caution.
# @set LOG_LEVEL string Log level of script
# @arg $1 string Log level of message
# @arg $2 string Message
# @arg $3 string `stderr` to output to stderr, otherwise then to stdout
# @arg $4 string ANSI escape color code
# @arg $5 string Command to run after log
# @stdout Show message if log level of message is less than runtime log level and $3 is not `stderr`
# @stderr Show message if log level of message is less than runtime log level and $3 is `stderr`
#######################################
function __log {
  declare -A log_levels=([trace]=5 [debug]=4 [info]=3 [warn]=2 [error]=1 [fatal]=0)
  declare -A log_colors=([trace]="1;30;47" [debug]="0;37;40" [info]="0;40" [warn]="0;33;40" [error]="1;31;40" [fatal]="1;37;41")
  local show_log_level="${1}"
  local msg="${2}"
  local out="${3:-stdout}"
  local color=${4:-${log_colors[${show_log_level}]}}

  __verify_log_level "$LOG_LEVEL"
  __verify_log_level "$show_log_level"

  local runtime_level_num="${log_levels[${LOG_LEVEL}]}"
  local write_level_num="${log_levels[${show_log_level}]}"

  [ "$write_level_num" -le "$runtime_level_num" ] || return 0

  if [[ "$out" == "stderr" ]]; then
    echo -e "\e[${color}m${msg}\e[0m" 1>&2
  else
    echo -e "\e[${color}m${msg}\e[0m"
  fi
}

#######################################
# @description Show debug message.
# @arg $1 string Message
# @stderr Show message if log level of message is less than debug level
#######################################
function dybatpho::debug {
  __log debug "DEBUG: ${*}" stderr
}

#######################################
# @description Show info message.
# @arg $1 string Message
# @stderr Show message if log level of message is less than info level
#######################################
function dybatpho::info {
  __log info "INFO: ${*}" stderr
}

#######################################
# @description Show in progress message.
# @arg $1 string Message
# @stdout Show message if log level of message is less than info level
#######################################
function dybatpho::progress {
  __log info "${*}..." stdout "0;36"
}

#######################################
# @description Show notice message with banner.
# @arg $1 string Message
# @stdout Show message if log level of message is less than info level
#######################################
function dybatpho::notice {
  local color="1;30;44"
  __log info \
    "================================================================================" \
    stdout "$color"
  __log info "${*}" stdout "$color"
  __log info \
    "================================================================================" \
    stdout "$color"
}

#######################################
# @description Show success message.
# @arg $1 string Message
# @stdout Show message if log level of message is less than info level
#######################################
function dybatpho::success {
  __log info "DONE: ${1}" stdout "1;32;40"
}

#######################################
# @description Show warning message.
# @arg $1 string Message
# @arg $2 string Indicator of message, default is `<invoke file>:<line number of invoke file>`
# @stderr Show message if log level of message is less than warning level
#######################################
function dybatpho::warn {
  local indicator=${2:-"${BASH_SOURCE[-1]}:${BASH_LINENO[0]}"}
  __log warn "$(date +"%FT%T") ${indicator} [WARNING]: ${1}" stderr
}

#######################################
# @description Show error message.
# @arg $1 string Message
# @arg $2 string Indicator of message, default is `<invoke file>:<line number of invoke file>`
# @stderr Show message if log level of message is less than error level
#######################################
function dybatpho::error {
  local indicator=${2:-"${BASH_SOURCE[-1]}:${BASH_LINENO[0]}"}
  __log error "$(date +"%FT%T") ${indicator} [ERROR]: ${1}" stderr
}

#######################################
# @description Show fatal message and exit process.
# @arg $1 string Message
# @arg $2 string Indicator of message, default is `<invoke file>:<line number of invoke file>`
# @stderr Show message if log level of message is less than fatal level
#######################################
function dybatpho::fatal {
  local indicator=${2:-"${BASH_SOURCE[-1]}:${BASH_LINENO[0]}"}
  __log fatal "$(date +"%FT%T") ${indicator} [FATAL]: ${1}" stderr
}

#######################################
# @description Start tracing script.
# @noargs
#######################################
function dybatpho::start_trace {
  [ "$LOG_LEVEL" != "trace" ] && return 1
  __log trace "START TRACE" stderr
  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  trap 'set +x' EXIT
  set -xv
}

#######################################
# @description Pause when tracing script.
# @noargs
#######################################
function dybatpho::pause_trace {
  [ "$LOG_LEVEL" != "trace" ] && return 1
  read -n 1 -s -r -p "Press any key to continue"
}

#######################################
# @description Hit breakpoint when tracing script.
# @noargs
#######################################
function dybatpho::breakpoint {
  [ "$LOG_LEVEL" != "trace" ] && return 1
  local REPLY
  local help='Breakpoint hit. [hopaAq]\nh: display help\no: list options\np: list parameters\na: list array\nA: list associative array\nq: quit'
  echo -e "$help"
  while read -r -N1; do case $REPLY in
    h) echo -e "$help" ;;
    o)
      shopt -s
      set -o
      ;;
    p) declare -p | less ;;
    a) declare -a ;;
    A) declare -A ;;
    q) return ;;
  esac done
}

#######################################
# @description End tracing script.
# @noargs
#######################################
function dybatpho::end_trace {
  set +xv
  [ "$LOG_LEVEL" = "trace" ] && __log trace "END TRACE" stderr
}
