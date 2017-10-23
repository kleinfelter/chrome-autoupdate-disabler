#!/bin/sh
# This script was generated using Makeself 2.3.1

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1388703776"
MD5="ec8ad321e903ea29e36578e4f2e9085b"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="Chrome Extension Auto-update Disabler Helper App"
script="./install-manifest-and-helper.sh"
scriptargs=""
licensetxt="Copyright (c) 2017 Kevin P. Kleinfelter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."
helpheader=''
targetdir="helper-mac-installer"
filesizes="3894"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi
	
if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo "$licensetxt"
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.3.1
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory
                        directory path can be either absolute or relative
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
	test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 575 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" = x"$crc"; then
				test x"$verb" = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 24 KB
	echo Compression: gzip
	echo Date of packaging: Mon Oct 23 17:39:01 EDT 2017
	echo Built with Makeself version 2.3.1 on darwin15
	echo Build command was: "/usr/local/bin/makeself \\
    \"--complevel\" \\
    \"9\" \\
    \"--license\" \\
    \"license\" \\
    \"/tmp/helper-mac-installer/\" \\
    \"installer.sh\" \\
    \"Chrome Extension Auto-update Disabler Helper App\" \\
    \"./install-manifest-and-helper.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"helper-mac-installer\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=24
	echo OLDSKIP=576
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 575 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 575 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir=$TMPROOT/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n 575 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 24 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
	MS_Printf "Uncompressing $label"
fi
res=3
if test x"$keep" = xn; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace $tmpdir`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 24; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (24 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test x"$keep" = xn; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res
� ua�Y�[yo�8������i,�j��"����&�:A;��-ѶjYҊRlO����I���$�tgw��D��?>�ZO�𲳳s��9�/�'��S>������yvvw���O~@IyBc`e�n���v�1c��B��"O�G��r©5����آi��Kf���}�a�M�qp����{U���w�������Һ����!z@�L?"�=z����e܉�(�� ��hG�<a�d��(��d�=.ڗo���_;g�}��<q�P���Θk��7����*�qNY3�Պ�ާ���.��O�h2�&��Ѝ��؀MZ:t�ѾhO��jI�[�⿄�{/_�����&�D�����5��nI�H��C��i��F�4
�L�[&k6�0�YVs��^2|���5��v#?dm�|rc;�`�n�Y��{Ӝ0���4���[��d����d��"oƓ8u��I`��3Ms� �,@r�1yM}��7B���H3N����=$|����g@`���֒�ZN<H"g�&!�IcF�16�F�6Jħ�7d�aB�0H��fɨ/�l�3a����������	u�z����1�n|���7\x��"�Y���7����Z�{i_������NT��� ����kW'��N�YAۼ��jwߞ�.����ݽCk���(庡i�I����3�]���u�w�#H�߭�7@gj����������F��J�{�i�'�N���3����2���K�`��� 8x"8���5b�i��(a��&���~�Zo���g����ߗ���W�"�&��W���������2�/*�.3{�뼿x����Y�U���K���J��wa�{zv���,�y�Z2X��Cl��9$2@���7�Č��Y	\�D�I�ck{	3�_/~=鼼zCtPJ	�ƪC?�c��a�J�@\:�S@Dҹe�ٌ�C�m��8��Ɯ1s&����Ih� ��`@���(�Q�ɘ�2hEd��%����Θ��&�-�0��_)��D���.�6 T�����E�<N���P�)hK��aH�b�Y�zi��!�M�9M���C��P0�0Q(E�C*�>5|� ���v-�F�����h�g���I>bP� �O|��q�h��A�Uh�A�	@J�	���Y�e�C�$Tzz�b��8�a��뻷�	�>���\v�``3I>o`�y��`*��gL�L@�`�9PTȿMf���LxpK�=G3�<β�ԟ�k 2���-�S�02��KR.{�<�kÈ%Ɍ�h
���w�y�;+f�58x�O��g��W��}��s�iJ塼���oJ-���+5h$�XE7d�
9z$h�A~A%d��pf�iM+\NAL��ر1{��.�Y�����4���ɗ�$�q�-��U-a�\y�5�����p\��R�XH�5��cQ�*XS�}F����$'��h�b��2��!���T"cւD��w!�4��fV+ݲ�H�p�v��rh��d�>G!L�m�� 4`0T�Pa� w];U����������.�j�.sQ���)}��Э�ջ�����:��("xu8~c�hr2ϧ~��="t F�=ۀ�8.@���2��@������:��ra,��?e.5�e�}��VƐ�hKًbYU������KI1�W�P⬀�rʯ�	�W%�wU�	���ėh`��������mR�q7��2��DS�n@@T�k�ڳ{5ګ�H�,fC��9v��؞1ayT��^�cXߝP�� s�b�+R_�k2j��^�Η;�V���~��]��� �'����~�Ы^�������Zt8\b��6�0����ab����$g�YL̂	��4��V)_�6d¹�9T���@���R.�$o6�3 "Fw��f{lfN�Q
ȡe��,�Ɗ؄R�eM�r��&؊���J̪g;r�Ai������P^VH���o�J�]��V+zSɖ�ybC����=X$�W[^ %8P3��/�޾s���H�a 6���em� ]�$�(�e~��8���k1�A0�)��g8%C�ږ
�{���8.��b�Y+"�LL�3���o\���]�UQj߰\�@Zai2l�M%R��dC<Q��-?�.�YB6NA
)4.@�I8�=���	;"���K��G_D7|��-�1a�| ���P)�^C���Y-�3"�Ci�pcJrVr칍�n�׀��kxBjJL�&�3�P�8&�g�`v���O�9IlbQ��X��}�wq~���Mɗ2A��(;J+���+�.�5�֑��ޖD�Q���&�RP�h�1�62s4�F �
&���]r�W#��F���"�Y"+,#����,�u
���4����M���1կQ�Wi��9�2T��Q����K�V����٤�L�"�B�q9���9(��L��8N;&z�.5�[,h)��r��<��)~�[����g_�9�r�����cG]�*Œ�g�U~��K;Hc���Y<��?m�]�ak�?Y�(��/���v{��X�x�j)��Wg#^�$�T��5�V�\J1�M���4���S�|`�Kp���<g��.��8� ���&����@l9�]Hq�ee��6��s]yZ�{����p�6�=�[CA�QEP&�BnI�%Xx�#6+U�N=��E�JV�!؅T�^��Jh�{�����qY.�"[�^��M�Fm+ɗ�Ȇ+3�ܚD.Ĝ5�wҼ�}�h63�[�>�$,�P���k 	Yx%#�Ⱥ��� �ҰkP;�L}-Y�G���
��,����J �X=�4�|��/�Y�*�%�(�U���Y<t���LLK�1ʪ����Y��wsT������u��v��M�ig^��(��j����t���Ɗ�������ꓢ�*Գp�Y�A�[Vxb�?��=���n��['N��_-�ܐ4�Ņ�1	��6���/O���k��Gdt�;�U�%@�:LV�|�s��;c�'�2˕�<����	b'.��CE�G��"&�
qy�.�]]z#ͦL���E��l����]�#�C"�P�q�0by��'h���y�qa(�\��!H/$��t�c�ݖ8��L5���i��&��!���/6q�'<j��{���=�]Z���'�&�n�^V2O��Ȯ)��������;����D &Ѐ[����ꕻ<U�-[��̤�WP�N��:�(�G�~�l�����<�֋<�BE��-m�݋���4�d8�	�̻�nd��|����Fn��]	��h[;P	cm-�A䩙�=%Ŕ��r�o�^�Y^.r�&�Ң�bH�$�b�&b���(r�G���I �*���|�Y��{�Ѡq��{��U7����7������?���������7����_��;�|�1g}� [p^��3,�ҵ�H�>9}�?}{��󀛛2ʳ��!@oK����>k����W$]�ѭ�yw]L���'�t���̫Nn��1�$Zɯ�b(=HoT&�z1^/,���< �C�{䣺w�vD�C�z�#�ĥ̌�2��6�4m:�I3��d���S.�� ��9c�NI�,�մ�=�\~��m�+y�(���-��i�M�q�3��k�ޫ�E��.�=��oA��[_4:jz�#MSU���G�����U����(|6�T�]�F*���K���0q;0��	ƫ���u]��`�K��H�L������>���������?���`�f\�Ex�UdȠ=�TK����kS6eS6eS6eS6eS6eS6eS6eS6eS6eS���?�� P  