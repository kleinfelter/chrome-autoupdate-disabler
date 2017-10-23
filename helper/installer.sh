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
‹ uaîYí[yoÛ8ïßú¥€äi,çj³È"¸Ûã&Ù:A;ˆ³-Ñ¶jYÒŠRlOÑıìûI¶Ó$ítgwÌ¶Dòñ?>¶ZOşğ²³³søü9Ÿ/ä'”ìS>ìîïî¼ØyvvwŸçO~@IyBc`eÂn½àv³1cşİB–„"OşGŠÕrÂ©5ñ™™Ÿ°Ø¢i¦‘Kf»§Ş}âağMöqp°Şşû{UûïıwŸıÿğÒº·ıµÏ!z@§L?"ú=zéÛØÁeÜ‰½(ñÂ û­hGØ<a‡dÌü(ëÑdŒ=.Ú—oíËó_;gò}²ˆ<q½P¾¢¾Î˜k‡±7òµ×ğ*œqNY3à¨ÕŠ†Ş§‘ë‡.£ƒOÃh2ô&ÓÉĞ¨ÏØ€MZ:t½Ñ¾hOşÅjI[Ñâ¿„ÿ{/_ÔğÿùŞ&şDÙú©•ò¸5ğ‚nI´HÆêCÂÇiâùFŞ4
ã„LÃ[&k6…0òYVs à^2| ñâ5ÔÈv#?dmğ»|rc;«`óˆnÊY¬ˆ{Óœ0‡˜Œ4õòì[äÓdÆÓì»dßù"oÆ“8u’ìI`˜ú3MsÙ Ù,@rÉ1yM}¯·7B¥±H3N’Ãñ=$|Ï…áÈg@`¸¾õÖ’öZN<H"gˆ&!ÜIcF’16ÇFæ6JÄ§æ7dœaBœ0H¨ˆfÉ¨/ÛlÃ3aÈŞÖÆÌà„’Øã	uÏz€‚ ï¤1÷n|Ÿ†®7\xÁÈ"„Yğ³¡7·«…¬Z»{i_½ïÚİöËNT¢÷õ ÌÌçó¾®kW'íËN½YAÛ¼ûÍî¿jwß÷.¡Şä Âİ½Ckşì¶á(åº¡iÚIûı‡Ó3û]ûìôu§wÙ#Hñß­®7@gjµ£È÷Šóé¥š¯õF õJ {ë„iê'­N†ò¼õ3ü™ÒÀ2ˆÉK×`ŒÃò 8x"8½‡5b‰i¦Û(aÛØ&ú«£~İZoû”g ‰¾ä­ß—ÌõûWà"ä„&´ßWŒöû§ışÏâï2³/*Ü.3{Õë¼¿xşú´ÛYæU°Òğ Kğª¬JÉÑwa¶{zvõ±Æ,ÜyèZ2XšÎCl…Á9$2@£Ø“7ÄŒî‰Y	\õD¾I‹ck{	3õ_/~=é¼¼zCtPJ	ôÆªC?åc³¡aèJ¥@\:„S@DÒ¹eñ‚ÙŒŒC°m¥ƒ8œ¡Æœ1s&œÀÑIh° †`@äÉÇ(¦QÄÉ˜Ş2hEdÔˆ%‹¼Æ§Î˜„Û&À-0æì_)¨ÁD ´–.¡6 T¼˜ÌÂØE<N¦ŒÂP¢)hKÀñaH¤b€Y‰ziÉÓ!¾MÒ9M“³„CÜP0‰0Q(EœC*Ó>5|Ÿ „úv-ĞF¬Ôª ‹h¹g‘öÙI>bPî O|ôéqÈhÓí A˜Uh§AÓ	@J–	éÎYûe·CŠ$Tzz’b„˜8±a– ë»·ä	Ø>•§¡\vÚ``3I>o`İyíÅ`*áÈgLL@`¥9PTÈ¿Mf¬¤²LxpK‘=G3Î<Î²¦ÔŸk 2õæĞ-òS˜02ßKR.{Ï<˜kÃˆ%ÉŒØh
¾²Àw¥yä;+fÔ58xÏOãˆ¶gãĞWÌç}–‚s™iJå¡¼¼oJ-Ê‚î+5h$ßXE7dÀ
9z$h™A~A%dàpfÇiM+\NAL˜şØ±1{–Û.óYÂ…©„àÉ4²ÁÇÉ—µ$Úqğ-‡ÙU-a¾\yÖ5Ê«ª¢†p\ÓĞR¸XH©5–ûcQÜ*XSš}F•›ğ‡$'ıÀh¬b²°2²š!ğ±ø°T"cÖ‚D»›w!¤4¦“fV+İ²¤Hñ¦pÜvÁôrhŒd³>G!Lâmæú 4`0TåPaÉ w];U„ùº°¾ŒÓÿ—¨.ûj½.sQ£’ó)}µ’Ğ­÷Õ»°ñ¯¥ÆÒ:Â€­("xu8~cÌhr2Ï§~šë ="t F¿=Û€¾8.@±¥ò2ÿ@úóÛù»¸:–ˆra,¬„?e.5ÄeÛ}üåVÆ›hKÙ‹bYUëÛ‘ ’«KI1éWµPâ¬€ÚrÊ¯¿	ÂW%´wUï	ÍÉÄ—h`ì•Òşµ’êëÚmR¡q7ıı2ıòDSän@@T®kÖÚ³{5Ú«åªH±,fCùÌ9v†¶Ø1ayTô­^cXßP˜¹ s©b†+R_Ík2j½»^Î—;×V’«û~ğ–]¥ŞĞ Û'õåüÛ~¼Ğ«^§ª­¯µõÁZt8\b¬Ü6¦0“ÎÜab«–çÁ$gÆYLÌ‚	›á4©V)_¹6dÂ¹¸9TŠÏß@¤¬°R.¹$o6¤3 "Fw¸ïf{lfN®Q
È¡e¼ˆ,§ÆŠØ„RÍeMÕràş&ØŠÖãÕJÌªg;rãAi™¨¯‚óÕP^VH±ÊoòJ¥]äÇV+zSÉ–°ybC¸’±=X$ÙW[^ %8P3òò/õŞ¾sşÎâHâa 6¨™êemÃ ]®$È(Äe~Ââ8€ék1™A0Î)¬åg8%CÛÚ–
›{‰¹£8.±Šb‰Y+"êLLÃ3¶—¥o\ïÜä]—UQjß°\æ@Zai2lşM%R¸…dC<Qè‹ß-?¤.ıYB6NA
)4.@•I8¤=áæü	;"Ÿ©KG_D7|„Õ-Ğ1aÂÍ| åÍĞP)Ş^Cû›åY-¦3"¸CipcJrVrì¹än”×€’ÑkxBjJLü&ê3„Pö8&Ægá`v©°O9IlbQñÅXæì}§wq~Öë¦MÉ—2A‘¬(;J+‚Ñ+³.5Ö‘Ì÷Ş–DµQ™”·&éŸRP¹h 1Ë62s4˜F Ø
&æòÜ]rèW#œ¥F÷ ¼"ÕY"+,#— Øİ,ò‚u
ñËö4õ¢¿¾Mô¬ƒ1Õ¯QËWi©ö9©2TßÙQ¬´³ìKäVŞï°ÄùÙ¤¶L¢"àBºq9§ó9(›êLËò8N;&z£.5Æ[,h)—àrƒ»<«•)~¥[¡¤¯g_õ9ärÏŒúæåcG]ê¹*Å’©g™U~† K;Hcíù˜Y<˜Æ?mû]ïakÀ?Yß(µİ/µµí§•v{­¶XÊxÀj)¯™Wg#^Ô$ñ¢šTàÄ5¿VŞ\J1ÆM‘¦Š4³Ú÷Sñˆ…|`ÒKp®¾ <gÄó.Ï¢8„ ™â¾&¸¿êĞ@l9Ñ]Hqáeeÿµ6ĞØs]yZ‹{²áÏp‡6‰=œ[CAäQEP&«BnIü%Xx¹#6+U±N=÷òEëJVä!Ø…T‡^ÉØJhç{Á–°îqY."[®^ÈõMşFm+É—È†+3šÜšD.Äœ5¾wÒ¼Ş}‹h63ğ[Í>´$,´P†»¼k 	Yx%#áÈº©Ë® ÉÒ°kP;íL}-Y˜Gª…
ÂÚ,ãÆÊÆJ ÕX=Õ4¤|À‚/àYæ*š%¯(šU¨ñÂ…ĞY<t–ÕLLK²1ÊªÚâ©ÏYõµwsT¿”ø¬ıu©ıv­ıM–ig^á¦Ó(÷Šj®ÕşĞt•”ñÆŠ½ÎÙÉéÙÙê“¢±*Ô³p„YÛA‘[VxbÍ?ó‚ı=µìÏn®ğ['NÔ_-ÎÜ4‹Å…Ø1	ÍÆ6´ŸÛ/OÏÚïkÜÑGdt«;©UÆ%@Ÿ:LVØ|¸sËÈ;c¸'2Ë•ˆ<Œ†˜…	b'.®²CEÁGÛÙ"&ç
qyº.ƒ]]z#Í¦L‰šĞEŒÕlŞïêû]Ï#âC"PáµqÔ0by›Ò'h‹§Æyóqa(ã\òã!H/$§Ìt‚cãİ–8ô­L5¿üòi±Æ&ÂÔ!‰¤“/6qÎ'<jó—{¸¥İ=ï]Z¸€÷'¼&¡nŠ^V2O¨ÑÈ®)¿”÷âÌ·ª;‘¦‹ÕD &Ğ€[•­»åê•»<Uš-[ú‰Ì¤¼WPãNœˆ:á(¹Gâ~ôlˆˆëÔã<»Ö‹<ÉBE»Û-m‹İ‹­•™4„d8Á	®Ì»—nd¤°|˜ƒÖFnŠí]	°h[;P	cm-àAä©™¤=%Å”¤ør o’^‰Y^.r¾&üÒ¢î‘bHß$†b¸&bş½„(rµGŠ€¾I Á*²Ÿ|ç¨Yìæ¡{ßÑ qŞç{ÜÿU7•š™ó7«¦ºÌÇ?à÷»Ï÷ê÷÷÷7÷ÿÔı_¼û; |¬1g}À [p^¾Û3,ËÒµìHÄ>9}¬?}{ş®ó€››2Ê³¡·!@oK×ğèÕ>k¿ëßãW$]åÑ­§yw]L‡×ä'Òt‰ş´Ì«NnÈß1£$ZÉ¯b(=HoT&äz1^/,½Ôö< ï¨CÎ{ä£ºwóvDªC–zÿ#õÄ¥ÌŒä2«æ®6ô4m:I3†•dºæàS.–Ü ©¤9cÈNIø,®Õ´ê=‘\~é¿¯m‘+yî(öå-íê­iüMÆqÑ3§¦kŞ«öEçÄ.š=ıœoAé÷[_4:jz°#MSU«øGëé…–şU‰”ğé(|6ÏT…]¡F*œèêK­«Ø0q;0»°	Æ«©¶Şu]¯Ü`ÿK¿ÿHƒLˆï…÷ııß>¼¬âÿÁÁÎæ÷?ÿÿì`üf\ÆExñUdÈ =TKÿ‹ü´kS6eS6eS6eS6eS6eS6eS6eS6eS6eSşâå?£ë P  