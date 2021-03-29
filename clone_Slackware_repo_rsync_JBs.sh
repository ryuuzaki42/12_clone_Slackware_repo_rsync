#!/bin/bash
#
# Autor= João Batista Ribeiro
# Bugs, Agradecimentos, Criticas "construtivas"
# Mande me um e-mail. Ficarei Grato!
# e-mail: joao42lbatista@gmail.com
#
# Este programa é um software livre; você pode redistribui-lo e/ou
# modifica-lo dentro dos termos da Licença Pública Geral GNU como
# publicada pela Fundação do Software Livre (FSF); na versão 2 da
# Licença, ou (na sua opinião) qualquer versão.
#
# Este programa é distribuído na esperança que possa ser útil,
# mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO a
# qualquer MERCADO ou APLICAÇÃO EM PARTICULAR.
#
# Veja a Licença Pública Geral GNU para mais detalhes.
# Você deve ter recebido uma cópia da Licença Pública Geral GNU
# junto com este programa, se não, escreva para a Fundação do Software
#
# Livre(FSF) Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Script: Clone some Slackware repository to a local source using rsync
#
# Last update: 28/03/2021
#
# Tip: Use this script with a "old" local mirror (or ISO) to download less files
#
input1=$1
if [ "$input1" == "noColor" ]; then
    echo -e "\\nColors disabled"
else
    # Some colors for script output - Make it easier to follow
    BLACK='\e[1;30m'
    RED='\e[1;31m'
    GREEN='\e[1;32m'
    NC='\033[0m' # reset/no color
    BLUE='\e[1;34m'
    PINK='\e[1;35m'
    CYAN='\e[1;36m'
    WHITE='\e[1;37m'
fi

if [ "$input1" == "testColor" ]; then
    echo -e "\\n\\tTest colors: $RED RED $WHITE WHITE $PINK PINK $BLACK BLACK $BLUE BLUE $GREEN GREEN $CYAN CYAN $NC NC\\n"
fi

mirrorSource="rsync://ftp.osuosl.org/slackware"
echo -e "$CYAN\\nDefault mirror:$GREEN $mirrorSource$NC"

echo -en "$CYAN\\nWant change the mirror?$NC\\n(y)es - (n)o $GREEN(press enter to no):$NC "
read -r changeMirror

if [ "$changeMirror" == 'y' ]; then
    mirrorSource=''

    while echo "$mirrorSource" | grep -v -q "rsync"; do
        echo -en "$CYAN\\nType the new mirror:$NC "
        read -r mirrorSource

        if echo "$mirrorSource" | grep -v -q "rsync"; then
            echo -e "$RED\\nError: the mirror \"$mirrorSource\" is not valid.\\nOne valid mirror has \"ftp\" or \"http\"$NC"
        fi
    done
    echo -e "$CYAN\\nNew mirror:$GREEN $mirrorSource$NC"
fi

if find . -maxdepth 1 -type d | grep -q "current"; then
    defaultSuggest="current"
else
    defaultSuggest="14.2"
fi

echo -en "\\n$CYAN# Most downloaded versions:$GREEN 14.0, 14.1, 14.2, current$CYAN\\nWith version Slackware you want? $GREEN(press enter to $defaultSuggest):$NC "
read -r versionSlackware

if [ "$versionSlackware" == '' ]; then
    versionSlackware=$defaultSuggest
fi

if echo "$versionSlackware" | grep -qv "current"; then # If not Slackware, can downlad only the updates
    if find . -maxdepth 1 -type d | grep -q "$versionSlackware"; then # If found a old download, can suggest the updates only
        echo -e "\\n\\t$RED#---------------------------------------------------------------------------------#"
        echo -e "$CYAN\\t# This option set to download only the updates - Useful to update the local mirror"
        echo -en "$CYAN\\t# Downlad only the patches (patches/)? (y)es - (n)o $GREEN(press enter to yes):$NC "
        read -r onlyPatches

        if [ "$onlyPatches" == '' ] || [ "$onlyPatches" == 'y' ]; then
            onlyPatches='y'
            echo -en "\\n$BLUE# Downloading only the patches #\\n$NC"
        else
            echo -en "\\n$BLUE# Downloading all the files #\\n$NC"
        fi
    fi
fi

echo -en "$CYAN\\nWith arch you want?$NC\\n(1) - 32 bits or (2) - 64 bits $GREEN(press enter to 64 bits):$NC "
read -r choosedArch

if [ "$choosedArch" == '1' ]; then
    choosedArch='' # Slackware 32 bits has folder name slackware-Version
else
    choosedArch="64" # Slackware 64 bits has folder slackware64-Version
fi
versionDownload="slackware$choosedArch-$versionSlackware"

echo -en "$CYAN\\nWant download the source code?$NC\\n(y)es - (n)o $GREEN(press enter to no):$NC "
read -r downloadSource

echo -en "$CYAN\\nWant download the \"testing/\" (folder - packages)?$NC\\n(y)es - (n)o $GREEN(press enter to no):$NC "
read -r downloadTesting

echo -en "$CYAN\\nWill download (by rsync) $GREEN\"$versionDownload\"$CYAN"
if [ "$downloadSource" == 'y' ]; then
    echo -en "$RED with $CYAN"
else
    echo -en "$RED without $CYAN"
fi
echo -en "the$BLUE source code$CYAN and"

if [ "$downloadTesting" == 'y' ]; then
    echo -en "$RED with $CYAN"
else
    echo -en "$RED without $CYAN"
fi
echo -e "the$BLUE \"testing/\"$CYAN from $GREEN\"$mirrorSource\"$NC"

echo -en "$CYAN\\nWant continue?$NC\\n(y)es - (n)o $GREEN(press enter to yes):$NC "
read -r contineRsync

if [ "$contineRsync" == 'n' ]; then
    echo -e "$CYAN\\nJust exiting by user choice$NC\\n"
else
    if [ "$downloadSource" != 'y' ]; then
        removeSoure="--exclude={'source/','patches/source/','pasture/source/'}"
        grepRemove=$removeSoure
    fi

    if [ "$downloadTesting" != 'y' ]; then
        removeTesting="--exclude \"testing/\""
        grepRemove=$grepRemove$removeTesting
    fi

    if [ "$onlyPatches" == 'y' ]; then
        onlyPatchesDl="--exclude={'EFI/','extra/','isolinux/','kernels/','pasture/','slackware64/','testing/','usb-and-pxe-installers/'}"
        grepRemove=$grepRemove$onlyPatchesDl
    fi

    # Remove "--exclude", " ", "={", "," and "}" form grepRemove
    grepRemove=$(echo "$grepRemove" | sed 's/\-\-exclude//g'| sed 's/ //g' | sed 's/={//g' | sed 's/,//g' | sed 's/}//g')

    # Change """, "'" and "||" in "|" and remove "^|" and "$|"
    grepRemove=$(echo "$grepRemove" | sed 's/"/|/g' | sed 's/'\''/|/g' | sed 's/||/|/g' | sed 's/^|//g' | sed 's/|$//g' )

    if [ -e $versionDownload/ ]; then
        echo -e "$CYAN\\nOlder folder download found ($GREEN$versionDownload/$CYAN)$NC"

        echo -en "$CYAN\\nDownloading$BLUE ChangeLog.txt$CYAN to make a$BLUE fast check$CYAN (the$BLUE local$GREEN "
        echo -en "ChangeLog.txt$CYAN with the$BLUE server$GREEN ChangeLog.txt$CYAN).$NC Please wait..."
        rsync -aqz "$mirrorSource/$versionDownload/ChangeLog.txt" ./ChangeLog.txt

        cd "$versionDownload" || exit
        changeLogLocalMd5sum=$(md5sum ChangeLog.txt)
        cd ../ || exit

        checkChangeLogMd5sum=$(echo -e "$changeLogLocalMd5sum" | md5sum -c 2> /dev/null)

        changeLogMd5sumResult=$(echo -e "$checkChangeLogMd5sum" | awk '{print $2}')

        echo -en "$CYAN\\nThe$BLUE ChangeLog.txt$CYAN in the server is"
        contineOrJump='y'
        if [ "$changeLogMd5sumResult" == "OK" ]; then
            rm ChangeLog.txt

            echo -e "$GREEN equal$CYAN with the$BLUE ChangeLog.txt$CYAN in local folder"
            echo -e "\\n\\t$RED#-----------------------------------------------------------#"
            echo -e "$CYAN\\t# Want continue/force the download or jump the download step?"
            echo -en "$NC\\t# (y)es to continue - (n)o to jump $GREEN(press enter to no):$NC "
            read -r contineOrJump

        else # $changeLogMd5sumResult == FAILED
            echo -e "$RED different$CYAN from the$BLUE ChangeLog.txt$CYAN in local folder$NC"
            echo -en "$CYAN\\nWant view the diff between these files?$NC\\n(y)es - (n)o $GREEN(press enter to yes):$NC "
            read -r diffChangLog

            if [ "$diffChangLog" != 'n' ]; then
                echo
                diff -u ChangeLog.txt $versionDownload/ChangeLog.txt
            fi
            rm ChangeLog.txt
        fi

        if [ "$contineOrJump" == 'y' ]; then
            echo -en "$CYAN\\nCreate a md5sum for all local files (${RED}can take a while$CYAN)? $NC\\n(y)es or (n)o $GREEN(press enter no):$NC "
            read -r useMd5sumCheckBeforeDownload

            if [ "$useMd5sumCheckBeforeDownload" == 'y' ]; then
                tmpMd5sumBeforeDownload=$(mktemp)
                listOfFilesBeforeDownload=$(find $versionDownload/ -type f -print)

                echo -en "$CYAN\\nCreating a$BLUE md5sum$RED (before the download)$CYAN from files found (in the folder $GREEN$versionDownload/$CYAN).$NC Please wait..."
                for file in $listOfFilesBeforeDownload; do
                    md5sum "$file" >> "$tmpMd5sumBeforeDownload"
                done
                echo -e "$CYAN\\n\\nThe$BLUE md5sum$RED (before the download)$CYAN was saved in the tmp file: $GREEN$tmpMd5sumBeforeDownload$NC"
            else
                tmpMd5sumBeforeDownload=''
            fi
        fi
    else
        contineOrJump='y'
    fi

    if [ "$contineOrJump" == 'y' ]; then
        rsyncCommand="rsync -ahv --delete --progress $removeSoure $removeTesting $onlyPatchesDl $mirrorSource/$versionDownload ./"

        # -a archive mode, equivalent to -rlptgoD - recursion and want to preserve almost everything
        # -h output numbers in a human-readable format; -v increase verbosity
        # --delete delete extraneous files from destination directories
        # --progress print information showing the progress of the transfer

        echo -en "$CYAN\\nDownloading files.$NC Please wait...\\n\\n"
        echo "$rsyncCommand"
        eval "$rsyncCommand"
    fi

    if [ "$tmpMd5sumBeforeDownload" != '' ]; then
        tmpMd5sumAfterDownload=$(mktemp)

        listOfFilesAfterDownload=$(find $versionDownload/ -type f -print)

        echo -en "$CYAN\\nCreating a$BLUE md5sum$RED (after the download)$CYAN from files (in the folder $GREEN$versionDownload/$CYAN).$NC Please wait..."
        for file in $listOfFilesAfterDownload; do
            md5sum "$file" >> "$tmpMd5sumAfterDownload"
        done
        echo -e "$CYAN\\n\\nThe$BLUE md5sum$RED (after the download)$CYAN was saved in the tmp file: $GREEN$tmpMd5sumAfterDownload$NC"

        echo -en "$CYAN\\nChecking the changes in the files$BLUE before$CYAN with$BLUE after$CYAN download.$NC Please wait..."
        changeResult=$(diff -w "$tmpMd5sumBeforeDownload" "$tmpMd5sumAfterDownload")

        if [ "$changeResult" == '' ]; then
            echo -e "$CYAN\\nNone changes made in the local folder -$GREEN All files still the same after the download$NC"
        else
            echo -e "$RED\\n\\nChanges made in local files...$NC"

            diffBeforeDownload=$(diff -u "$tmpMd5sumBeforeDownload" "$tmpMd5sumAfterDownload" | grep -v "^--" | grep "^-" | awk '{print $2}')
            diffAfterDownload=$(diff -u "$tmpMd5sumBeforeDownload" "$tmpMd5sumAfterDownload" | grep -v "^++" | grep "^+" | awk '{print $2}')

            for lineA in $diffBeforeDownload; do
                for lineB in $diffAfterDownload; do
                    if [ "$lineA" == "$lineB" ]; then
                        filesUpdate+=$lineA\|
                    fi
                done
            done

            if [ "$filesUpdate" != '' ]; then
                echo -e "$GREEN\\nFile(s) updated:$NC"
                echo "$filesUpdate" | sed 's/|/\n/g' | sort
            fi

            for lineA in $diffBeforeDownload; do
                diffLineDeleted=$(echo "$diffAfterDownload" | grep "$lineA")
                if [ "$diffLineDeleted" == '' ]; then
                    filesDeleted+=$lineA\|
                fi
            done

            if [ "$filesDeleted" != '' ]; then
                echo -e "$RED\\nFile(s) deleted:$NC"
                echo "$filesDeleted" | sed 's/|/\n/g' | sort
            fi

            for lineB in $diffAfterDownload; do
                diffLineNewFiles=$(echo "$diffBeforeDownload" | grep "$lineB")
                if [ "$diffLineNewFiles" == '' ]; then
                    filesNew+=$lineB\|
                fi
            done

            if [ "$filesNew" != '' ]; then
                echo -e "$BLUE\\nNew file(s) downloaded:$NC"
                echo "$filesNew" | sed 's/|/\n/g' | sort
            fi
        fi

        rm "$tmpMd5sumBeforeDownload" "$tmpMd5sumAfterDownload"
    fi

    cd "$versionDownload" || exit

    echo -en "$CYAN\\nWant check the integrity of downloaded files with the server?$NC\\n(y)es - (n)o $GREEN(press enter to yes):$NC "
    read -r checkFiles

    if [ "$checkFiles" == 'y' ] || [ "$checkFiles" == '' ]; then
        echo -en "$CYAN\\nChecking the integrity of the files.\\nIgnoring: $BLUE$grepRemove$NC\\nPlease wait..."
        checkFilesResult=$(tail +13 CHECKSUMS.md5 | grep -vE "$grepRemove" | md5sum -c --quiet)

        echo -en "$CYAN\\n\\nFiles integrity:"
        if [ "$checkFilesResult" == '' ]; then
            echo -e "$GREEN Good $BLUE- Files are equal to the server$NC"
        else
            echo -e "$RED Bad $BLUE- Files are different to the server$NC"
            echo -e "$RED$checkFilesResult$NC"
        fi
    fi

    echo -en "$CYAN\\nWant create a ISO file from downloaded folder?$NC\\n(y)es - (n)o $GREEN(press enter to no):$NC "
    read -r generateISO

    isoFileName="${versionDownload}_AllPkgs_date_"$(date +%d_%m_%Y)
    dateISO=$(date +%d_%b_%Y)
    localISO=$(pwd | rev| cut -d '/' -f2- | rev)

    commandGenISOPart1="mkisofs -o \"../${isoFileName}.iso\" \
-R -J -V \"Slackware-current DVD\" \
-hide-rr-moved -hide-joliet-trans-tbl \
-v -d -N -no-emul-boot -boot-load-size 4 -boot-info-table \
-sort isolinux/iso.sort \
-b isolinux/isolinux.bin \
-c isolinux/isolinux.boot \
-preparer \"Slackware-current build for x86_64 by ryuuzaki42 <github.com/ryuuzaki42/12_clone_Slackware_repo_rsync>\" \
-publisher \"The Slackware Linux Project - http://www.slackware.com/\" \
-A \"Slackware-current DVD - build $dateISO\" \
"

        commandGenISOPart3="-eltorito-alt-boot -no-emul-boot -eltorito-platform 0xEF -eltorito-boot isolinux/efiboot.img \
."

        commandGenISO=$commandGenISOPart1$commandGenISOPart3

    if [ "$generateISO" == 'y' ]; then
        olderIsoSlackware=$(ls "slackware*iso")

        if [ "$olderIsoSlackware" != '' ]; then
            echo -e "$CYAN\\nOlder ISO file Slackware found:$GREEN $olderIsoSlackware$NC"
            echo -en "$CYAN\\nDelete the older ISO file(s) before continue?$NC\\n(y)es - (n)o $GREEN(press enter to no):$NC "
            read -r deleteOlderIso

            if [ "$deleteOlderIso" == 'y' ]; then
                rm slackware*.iso
            fi
        fi

        echo -e "\\nCreating ISO file. Please wait..."

        echo -e "\\nRunning:\\n$commandGenISO\\n"
        eval $commandGenISO

        echo -e "\\nThe ISO file: $localISO/$isoFileName.iso\\nWas generated by the folder $appendMessage: $localISO/$folderWork\\n"

        if [ "$usePackagesList" == '2' ]; then
            echo -e "\\nTake a look in the files:"
            echo "$(pwd)/"
            echo -e "\\t\\t $(find $mkisofsExcludeList | rev | cut -d '/' -f1 | rev)"
            echo -e "\\t\\t $(find $filesIgnoredInTheISO | rev | cut -d '/' -f1 | rev)"
            echo -e "\\t\\t $(find $filesNotFound 2> /dev/null | rev | cut -d '/' -f1 | rev)"
        fi
    else
        echo -e "\\n\\nExiting...\\n\\nIf you want create a ISO file, use:\\n\\ncd $localISO/\\n\\n$commandGenISO\\n"
    fi
fi
