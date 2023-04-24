#!@MEMO_PREFIX@/bin/sh

@MEMO_PREFIX@@MEMO_SUB_PREFIX@/libexec/firmware
@MEMO_PREFIX@@MEMO_SUB_PREFIX@/sbin/pwd_mkdb -p @MEMO_PREFIX@/etc/master.passwd >/dev/null 2>&1
@MEMO_PREFIX@/Library/dpkg/info/debianutils.postinst configure 99999
@MEMO_PREFIX@/Library/dpkg/info/apt.postinst configure 999999
@MEMO_PREFIX@/Library/dpkg/info/dash.postinst configure 999999
@MEMO_PREFIX@/Library/dpkg/info/zsh.postinst configure 999999
@MEMO_PREFIX@/Library/dpkg/info/bash.postinst configure 999999
@MEMO_PREFIX@/Library/dpkg/info/vi.postinst configure 999999
@MEMO_PREFIX@/Library/dpkg/info/openssh-server.extrainst_ install @SSH_STRAP@

@MEMO_PREFIX@@MEMO_SUB_PREFIX@/sbin/pwd_mkdb -p @MEMO_PREFIX@/etc/master.passwd

@MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/chsh -s @MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/zsh mobile
@MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/chsh -s @MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/zsh root

SYS_LANG=$(sudo -u mobile deviceinfo locale)
MESSAGE="In order to use command line tools like \"sudo\" after jailbreaking, you will need to set a terminal passcode. (This cannot be empty)"
TYPE_PASSWORD="Password"
RETYPE_PASSWORD="Repeat Password"
SET="Set"
SET_PASSWORD="Set Password"

ZH_HANT(){
    MESSAGE="為了在越獄之後使用終端機命令例如 sudo ，您需要設定一個終端機密碼。（不能為空）"
    TYPE_PASSWORD="請輸入密碼"
    RETYPE_PASSWORD="請再次輸入密碼"
    SET="設定"
    SET_PASSWORD="設定密碼"
}

ZH_HANS(){
    MESSAGE="为了在越狱之后使用终端命令例如 sudo ，您需要设置一个终端密码。（不能为空）"
    TYPE_PASSWORD="请输入密码"
    RETYPE_PASSWORD="请再次输入密码"
    SET="设置"
    SET_PASSWORD="设置密码"
}

if [ "$SYS_LANG" = "zh_TW" ] || [ "$SYS_LANG" = "zh_HK" ] || [ "$SYS_LANG" = "zh_MO" ]; then
    ZH_HANT
elif [ "$SYS_LANG" = "zh_CN" ] || [ "$SYS_LANG" = "zh_SG" ]; then
    ZH_HANS
fi
if [ -z "$NO_PASSWORD_PROMPT" ]; then
    PASSWORDS=""
    PASSWORD1=""
    PASSWORD2=""
    while [ -z "$PASSWORD1" ] || [ ! "$PASSWORD1" = "$PASSWORD2" ]; do
            PASSWORDS="$(@MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/uialert -b "$MESSAGE" --secure "$TYPE_PASSWORD" --secure "$RETYPE_PASSWORD" -p "$SET" "$SET_PASSWORD")"
            PASSWORD1="$(printf "%s\n" "$PASSWORDS" | @MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/sed -n '1 p')"
            PASSWORD2="$(printf "%s\n" "$PASSWORDS" | @MEMO_PREFIX@@MEMO_SUB_PREFIX@/bin/sed -n '2 p')"
    done
    printf "%s\n" "$PASSWORD1" | @MEMO_PREFIX@@MEMO_SUB_PREFIX@/sbin/pw usermod 501 -h 0
fi

rm -f @MEMO_PREFIX@/prep_bootstrap.sh
