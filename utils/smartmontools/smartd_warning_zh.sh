#! /bin/sh
#
# smartd warning script
#
# Home page of code is: http://www.smartmontools.org
#
# Copyright (C) 2012-16 Christian Franke
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
# $Id: smartd_warning.sh.in 4839 2018-11-27 18:26:08Z chrfranke $
#

set -e

# Set by config.status
export PATH="/usr/local/bin:/usr/bin:/bin"
PACKAGE="smartmontools"
VERSION="7.2"
prefix="/usr"
sysconfdir="/etc"
smartdscriptdir="${sysconfdir}"

# Default mailer
os_mailer="mail"

# Plugin directory (disabled if empty)
plugindir="${smartdscriptdir}/smartd_warning.d"

# Parse options
dryrun=
case $1 in
  --dryrun) dryrun=t; shift ;;
esac

if [ $# != 0 ]; then
  cat <<EOF
smartd $VERSION warning message script

Usage:
  export SMARTD_MAILER='Path to external script, empty for "$os_mailer"'
  export SMARTD_ADDRESS='Space separated mail addresses, empty if none'
  export SMARTD_MESSAGE='Error Message'
  export SMARTD_FAILTYPE='Type of failure, "EMailTest" for tests'
  export SMARTD_TFIRST='Date of first message sent, empty if none'
  #export SMARTD_TFIRSTEPOCH='time_t format of above'
  export SMARTD_PREVCNT='Number of previous messages, 0 if none'
  export SMARTD_NEXTDAYS='Number of days until next message, empty if none'
  export SMARTD_DEVICEINFO='Device identify information'
  #export SMARTD_DEVICE='Device name'
  #export SMARTD_DEVICESTRING='Annotated device name'
  #export SMARTD_DEVICETYPE='Device type from -d directive, "auto" if none'
  $0 [--dryrun]
EOF
  exit 1
fi

if [ -z "${SMARTD_ADDRESS}${SMARTD_MAILER}" ]; then
  echo "$0: SMARTD_ADDRESS or SMARTD_MAILER must be set" >&2
  exit 1
fi

# Get host and domain names
for cmd in 'hostname' 'uname -n' 'echo "[Unknown]"'; do
  hostname=`eval $cmd 2>/dev/null` || continue
  test -n "$hostname" || continue
  break
done

dnsdomain=${hostname#*.}
if [ "$dnsdomain" != "$hostname" ]; then
  # hostname command printed FQDN
  hostname=${hostname%%.*}
else
  for cmd in 'dnsdomainname' 'hostname -d' 'echo'; do
    dnsdomain=`eval $cmd 2>/dev/null` || continue
    break
  done
  test "$dnsdomain" != "(none)" || dnsdomain=
fi

for cmd in 'nisdomainname' 'hostname -y' 'domainname' 'echo'; do
  nisdomain=`eval $cmd 2>/dev/null` || continue
  break
done
test "$nisdomain" != "(none)" || nisdomain=

# Format subject
export SMARTD_SUBJECT="主机 $hostname 检测到 S.M.A.R.T. 错误 (${SMARTD_FAILTYPE-[SMARTD_FAILTYPE]})"

# Format message
fullmessage=`
  echo "此消息由 smartd 守护进程生成："
  echo
  echo "   主机名: $hostname"
  echo "   DNS 域: ${dnsdomain:-[空]}"
  test -z "$nisdomain" ||
    echo "   NIS 域: $nisdomain"
  #test -z "$USERDOMAIN" ||
  #  echo "   Win 域: $USERDOMAIN"
  echo
  echo "smartd 守护进程记录了以下问题："
  echo
  echo "${SMARTD_MESSAGE-[SMARTD_MESSAGE]}"
  echo
  echo "设备信息："
  echo "${SMARTD_DEVICEINFO-[SMARTD_DEVICEINFO]}"
  if [ "$SMARTD_FAILTYPE" != "EmailTest" ]; then
    echo
    echo "你还可以使用 smartctl 实用程序进行进一步调查。"
    test "$SMARTD_PREVCNT" = "0" ||
      echo "关于此问题的原始消息发送于 ${SMARTD_TFIRST-[SMARTD_TFIRST]}"
    case $SMARTD_NEXTDAYS in
      '') echo "即使问题仍然存在，也不会继续发送有关此问题的消息。" ;;
      1)  echo "如果问题仍然存在，将在 24 小时内发送另一条消息。" ;;
      *)  echo "如果问题仍然存在，将在 $SMARTD_NEXTDAYS 天内发送另一条消息。" ;;
    esac
  fi
`

# Export message with trailing newline
export SMARTD_FULLMESSAGE="$fullmessage
"

# Run plugin scripts if requested
if test -n "$plugindir"; then
 case " $SMARTD_ADDRESS" in
  *\ @*)
    if [ -n "$dryrun" ]; then
      echo "export SMARTD_SUBJECT='$SMARTD_SUBJECT'"
      echo "export SMARTD_FULLMESSAGE='$SMARTD_FULLMESSAGE'"
    fi

    # Run ALL scripts if requested
    case " $SMARTD_ADDRESS " in
      *\ @ALL\ *)
        for cmd in "$plugindir"/*; do
          if [ -f "$cmd" ] && [ -x "$cmd" ]; then
            if [ -n "$dryrun" ]; then
              echo "$cmd </dev/null"
            else
              "$cmd" </dev/null
            fi
          fi
        done
        ;;
    esac

    # Run selected scripts
    addrs=$SMARTD_ADDRESS
    SMARTD_ADDRESS=
    for ad in $addrs; do
      case $ad in
        @ALL)
          ;;
        @?*)
          cmd="$plugindir/${ad#@}"
          if [ -f "$cmd" ] && [ -x "$cmd" ]; then
            if [ -n "$dryrun" ]; then
              echo "$cmd </dev/null"
            else
              "$cmd" </dev/null
            fi
          elif [ ! -e "$cmd" ]; then
            echo "$cmd: Not found" >&2
          fi
          ;;
        *)
          SMARTD_ADDRESS="${SMARTD_ADDRESS:+ }$ad"
          ;;
      esac
    done

    # Send email to remaining addresses
    test -n "$SMARTD_ADDRESS" || exit 0
    ;;
 esac
fi

# Send mail or run command
if [ -n "$SMARTD_ADDRESS" ]; then

  # Send mail, use platform mailer by default
  test -n "$SMARTD_MAILER" || SMARTD_MAILER=$os_mailer
  if [ -n "$dryrun" ]; then
    echo "exec '$SMARTD_MAILER' -s '$SMARTD_SUBJECT' $SMARTD_ADDRESS <<EOF
$fullmessage
EOF"
  else
    exec "$SMARTD_MAILER" -s "$SMARTD_SUBJECT" $SMARTD_ADDRESS <<EOF
$fullmessage
EOF
  fi

elif [ -n "$SMARTD_MAILER" ]; then

  # Run command
  if [ -n "$dryrun" ]; then
    echo "export SMARTD_SUBJECT='$SMARTD_SUBJECT'"
    echo "export SMARTD_FULLMESSAGE='$SMARTD_FULLMESSAGE'"
    echo "exec '$SMARTD_MAILER' </dev/null"
  else
    unset SMARTD_ADDRESS
    exec "$SMARTD_MAILER" </dev/null
  fi

fi
