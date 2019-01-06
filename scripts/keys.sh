shopt -s extglob

#
# keys.sh
#
# Helper script for handling keys.
#
# Author: konsolebox
# Copyright Free / Public Domain
# 2015/07/05
#


# Note: Using Log.fcall() here will destroy debug output.


KEYS_ESC=$'\e'
KEYS_F1=$'\e[[A'
KEYS_F2=$'\e[[B'
KEYS_F3=$'\e[[C'
KEYS_F4=$'\e[[D'
KEYS_F5=$'\e[[E'
KEYS_F6=$'\e[17~'
KEYS_F7=$'\e[18~'
KEYS_F8=$'\e[19~'
KEYS_F9=$'\e[20~'
KEYS_F10=$'\e[21~'
KEYS_F11=$'\e[23~'
KEYS_F12=$'\e[24~'
KEYS_HOME=$'\e[1~'
KEYS_INSERT=$'\e[2~'
KEYS_DELETE=$'\e[3~'
KEYS_END=$'\e[4~'
KEYS_PAGE_UP=$'\e[5~'
KEYS_PAGE_DOWN=$'\e[6~'
KEYS_UP=$'\e[A'
KEYS_DOWN=$'\e[B'
KEYS_RIGHT=$'\e[C'
KEYS_LEFT=$'\e[D'
KEYS_NUMPAD_EXTRA=$'\e[G'
KEYS_TAB=$'\t'
KEYS_ENTER=$'\n'
KEYS_SPACE=' '

KEYS_ALT_1=$'\e1'
KEYS_ALT_2=$'\e2'
KEYS_ALT_3=$'\e3'
KEYS_ALT_4=$'\e4'
KEYS_ALT_5=$'\e5'
KEYS_ALT_6=$'\e6'
KEYS_ALT_7=$'\e7'
KEYS_ALT_8=$'\e8'
KEYS_ALT_9=$'\e9'
KEYS_ALT_0=$'\e0'
KEYS_ALT_A=$'\ea'
KEYS_ALT_B=$'\eb'
KEYS_ALT_C=$'\ec'
KEYS_ALT_D=$'\ed'
KEYS_ALT_E=$'\ee'
KEYS_ALT_F=$'\ef'
KEYS_ALT_G=$'\eg'
KEYS_ALT_H=$'\eh'
KEYS_ALT_I=$'\ei'
KEYS_ALT_J=$'\ej'
KEYS_ALT_K=$'\ek'
KEYS_ALT_L=$'\el'
KEYS_ALT_M=$'\em'
KEYS_ALT_N=$'\en'
KEYS_ALT_O=$'\eo'
KEYS_ALT_P=$'\ep'
KEYS_ALT_Q=$'\eq'
KEYS_ALT_R=$'\er'
KEYS_ALT_S=$'\es'
KEYS_ALT_T=$'\et'
KEYS_ALT_U=$'\eu'
KEYS_ALT_V=$'\ev'
KEYS_ALT_W=$'\ew'
KEYS_ALT_X=$'\ex'
KEYS_ALT_Y=$'\ey'
KEYS_ALT_Z=$'\ez'
KEYS_ALT_APOSTROPHE=$'\e\''
KEYS_ALT_BACKQUOTE=$'\e\`'
KEYS_ALT_BSLASH=$'\e\\'
KEYS_ALT_COMMA=$'\e,'
KEYS_ALT_DASH=$'\e-'
KEYS_ALT_DOT=$'\e.'
KEYS_ALT_EQUAL=$'\e='
KEYS_ALT_ESC=$'\e\e'
KEYS_ALT_FSLASH=$'\e/'
KEYS_ALT_LBRACKET=$'\e['
KEYS_ALT_RBRACKET=$'\e]'
KEYS_ALT_SEMICOLON=$'\e;'
KEYS_ALT_SPACE=$'\e '
KEYS_ALT_TAB=$'\e\t'

KEYS_XTERM_F1=$'\eOP'
KEYS_XTERM_F2=$'\eOQ'
KEYS_XTERM_F3=$'\eOR'
KEYS_XTERM_F4=$'\eOS'
KEYS_XTERM_F5=$'\e[15~'
KEYS_XTERM_HOME=$'\e[H'
KEYS_XTERM_END=$'\e[F'


# Keys.read_once ([timeout], ['-q' | "--quiet" | "-n" | "--show-notations" | "-N" | "--show-notations-with-newline"])
#
# Reads a key from user's input.
#
# > __V0 = one or more characters representing the read key
# > __V1 = extra read character not part of the key
# > __V2 = key notation
#
function Keys.read_once {
	__V0='' __V1='' __V2=''

	local KEY=() S=() T=() SHOW_NOTATIONS=false WITH_NEWLINE=false USE_MINIWAITS=false

	for __; do
		case $__ in
		+([[:digit:]]))
			T=(-t "$__")
			;;
		-q|--quiet)
			S=(-s)
			;;
		-n|--show-notations)
			S=(-s)
			SHOW_NOTATIONS=true
			;;
		-N|--show-notations-with-newline)
			S=(-s)
			SHOW_NOTATIONS=true
			WITH_NEWLINE=true
			;;
		-m|--use_miniwaits)
			USE_MINIWAITS=true
			;;
		#begin_optional_block
		*)
			Log.fatal_error "Invalid argument: $__"
			;;
		esac
		#end_optional_block
	done

	local IFS=  ## Needed for reading and merging.
	local HAS_INPUT=false

	if [[ -n $T && ${USE_MINIWAITS} == true ]]; then
		for (( I = T[1]; I; --I )); do
			read -rn 1 -d '' -t 1 "${S[@]}" __ && HAS_INPUT=true && break
		done
	else
		read -rn 1 -d '' "${T[@]}" "${S[@]}" __ && HAS_INPUT=true
	fi

	if [[ ${HAS_INPUT} == true ]]; then
		KEY[0]=$__

		if [[ $__ == $'\e' ]]; then
			if [[ BASH_VERSINFO -ge 4 ]]; then
				T=(-t 0.05)
			else
				T=(-t 1)
			fi

			if read -rn 1 -d '' "${T[@]}" "${S[@]}" __; then
				case $__ in
				\[)
					KEY[1]=$__

					local I=2

					while
						read -rn 1 -d '' "${T[@]}" "${S[@]}" "KEY[$I]" && \
						[[ ${KEY[I]} != [[:upper:]~] ]]
					do
						(( ++I ))
					done
					;;
				O)
					KEY[1]=$__
					read -rn 1 -d '' "${T[@]}" 'KEY[2]'
					;;
				[[:print:]]|$'\t'|$'\e')
					KEY[1]=$__
					;;
				*)
					__V1=$__
					;;
				esac
			fi
		fi

		__V0="${KEY[*]}"

		case ${__V0} in
		"${KEYS_ESC}")
			__V2='[ESC]'
			;;
		"${KEYS_F1}"|"${KEYS_XTERM_F1}")
			__V2='[F1]'
			;;
		"${KEYS_F2}"|"${KEYS_XTERM_F2}")
			__V2='[F2]'
			;;
		"${KEYS_F3}"|"${KEYS_XTERM_F3}")
			__V2='[F3]'
			;;
		"${KEYS_F4}"|"${KEYS_XTERM_F4}")
			__V2='[F4]'
			;;
		"${KEYS_F5}"|"${KEYS_XTERM_F5}")
			__V2='[F5]'
			;;
		"${KEYS_F6}")
			__V2='[F6]'
			;;
		"${KEYS_F7}")
			__V2='[F7]'
			;;
		"${KEYS_F8}")
			__V2='[F8]'
			;;
		"${KEYS_F9}")
			__V2='[F9]'
			;;
		"${KEYS_F10}")
			__V2='[F10]'
			;;
		"${KEYS_F11}")
			__V2='[F11]'
			;;
		"${KEYS_F12}")
			__V2='[F12]'
			;;
		"${KEYS_HOME}"|"${KEYS_XTERM_HOME}")
			__V2='[HOME]'
			;;
		"${KEYS_INSERT}")
			__V2='[INS]'
			;;
		"${KEYS_DELETE}")
			__V2='[DEL]'
			;;
		"${KEYS_END}"|"${KEYS_XTERM_END}")
			__V2='[END]'
			;;
		"${KEYS_PAGE_UP}")
			__V2='[PGUP]'
			;;
		"${KEYS_PAGE_DOWN}")
			__V2='[PGDN]'
			;;
		"${KEYS_UP}")
			__V2='[UP]'
			;;
		"${KEYS_DOWN}")
			__V2='[DOWN]'
			;;
		"${KEYS_RIGHT}")
			__V2='[RIGHT]'
			;;
		"${KEYS_LEFT}")
			__V2='[LEFT]'
			;;
		"${KEYS_NUMPAD_EXTRA}")
			__V2='[?]'
			;;
		"${KEYS_ENTER}")
			__V2='[ENTER]'
			;;
		"${KEYS_TAB}")
			__V2='[TAB]'
			;;
		"${KEYS_SPACE}")
			__V2='[SPACE]'
			;;
		"${KEYS_ALT_SPACE}")
			__V2='[ALT-SPACE]'
			;;
		"${KEYS_ALT_TAB}")
			__V2='[ALT-TAB]'
			;;
		"${KEYS_ALT_ESC}")
			__V2='[ALT-ESC]'
			;;
		$'\e'[[:lower:]])
			__V2="[ALT-${__V0#$'\e'}]"
			[[ BASH_VERSINFO -ge 4 ]] && __V2=${__V2^^}
			;;
		$'\e'[[:print:]])
			__V2="[ALT-${__V0#$'\e'}]"
			;;
		*)
			__V2=${__V0//$'\e'/ESC}
			;;
		esac

		if [[ ${SHOW_NOTATIONS} == true && -n ${__V2} ]]; then
			echo -n "${__V2}${__V1%%+($'\n')}"
			[[ -n ${WITH_NEWLINE} ]] && echo
		fi

		return 0
	fi

	return 1
}


# Keys.flush ()
#
if [[ BASH_VERSINFO -ge 4 ]]; then
	function Keys.flush {
		local REPLY
		while read -s -n 1 -t 0.05; do continue; done
	}
else
	function Keys.flush {
		local REPLY
		while read -s -n 1 -t 1; do continue; done
	}
fi
