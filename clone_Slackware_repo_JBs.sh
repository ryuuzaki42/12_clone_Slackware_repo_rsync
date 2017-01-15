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
# Script: Clone some Slackware repository to a local source
#
# Last update: 15/01/2017
#
# Tip: Use the file inside one "old" ISO to make less things to download

input1=$1

if [ "$input1" == "noColor" ]; then
    echo -e "\nColors disabled"
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
    echo -e "\n\tTest colors: $RED RED $WHITE WHITE $PINK PINK $BLACK BLACK $BLUE BLUE $GREEN GREEN $CYAN CYAN $NC NC\n"
fi

mirrorSource="ftp://ftp.osuosl.org/.2/slackware/"
echo -e "$CYAN\nDefault mirror:$GREEN $mirrorSource$NC"

echo -en "$CYAN\nWant change the mirror?$NC\n(y)es - (n)o $GREEN(press enter to no):$NC "
read changeMirror

if [ "$changeMirror" == 'y' ]; then
    mirrorSource=''

    while echo "$mirrorSource" | grep -v -q -E "ftp|http"; do
        echo -en "$CYAN \nType the new mirror:$NC "
        read mirrorSource

        if echo "$mirrorSource" | grep -v -q -E "ftp|http"; then
            echo -e "$RED\nError: the mirror \"$mirrorSource\" is not valid.\nOne valid mirror has \"ftp\" or \"http\"$NC"
        fi
    done
    echo -e "$CYAN\nNew mirror:$GREEN $mirrorSource$NC\n"
fi

echo -en "$CYAN\nWith version Slackware you want? $GREEN(press enter to 14.2):$NC "
read versionSlackware

if [ "$versionSlackware" == '' ]; then
    versionSlackware="14.2"
fi

echo -en "$CYAN\nWith arch you want?$NC\n(1) - 32 bits or (2) - 64 bits $GREEN(press enter to 64 bits):$NC "
read choosedArch

if [ "$choosedArch" == '1' ]; then
    choosedArch=''
else
    choosedArch="64"
fi

versionDownload=slackware$choosedArch-$versionSlackware

echo -en "$CYAN\nWant download the source code?$NC\n(y)es - (n)o $GREEN(press enter to no):$NC "
read downloadSource

echo -en "$CYAN\nWill download (by lftp) $GREEN\"$versionDownload\"$CYAN"
if [ "$downloadSource" == 'y' ]; then
    echo -en "$RED with $CYAN"
else
    echo -en "$RED without $CYAN"
fi
echo -e "the$BLUE source code$CYAN from $GREEN\"$mirrorSource\"$NC"

echo -en "$CYAN\nWant continue?$NC\n(y)es - (n)o $GREEN(press enter to yes):$NC "
read contineLftp

if [ "$contineLftp" == 'n' ]; then
    echo -e "$CYAN\nJust exiting by user choice$NC\n"
else
    if [ -e $versionDownload/ ]; then
        echo -e "$CYAN\nOlder folder download found ($GREEN$versionDownload/$CYAN)$NC"

        echo -en "$CYAN\nDownloading$BLUE ChangeLog.txt$CYAN to make a$BLUE fast check$CYAN (the$BLUE local$GREEN "
        echo -e "ChangeLog.txt$CYAN with the$BLUE server$GREEN ChangeLog.txt$CYAN)$NC. Please wait...\n"
        wget $mirrorSource/$versionDownload/ChangeLog.txt -O ChangeLog.txt

        cd $versionDownload/
        changeLogLocalMd5sum=`md5sum ChangeLog.txt`
        cd ..

        checkChangeLogMd5sum=`echo -e "$changeLogLocalMd5sum" | md5sum -c 2> /dev/null`

        changeLogMd5sumResult=`echo -e "$checkChangeLogMd5sum" | awk '{print $2}'`

        echo -en "$CYAN\nThe$BLUE ChangeLog.txt$CYAN in the server is"
        contineOrJump='y'
        if [ "$changeLogMd5sumResult" == "OK" ]; then
            rm ChangeLog.txt

            echo -e "$GREEN equal$CYAN with the$BLUE ChangeLog.txt$CYAN in local folder$NC"
            echo -en "$CYAN\nWant continue/force the download or jump the download step?$NC\n(y)es to continue - (n)o to jump $GREEN(press enter to no):$NC "
            read contineOrJump

        else # $changeLogMd5sumResult == FAILED
            echo -e "$RED different$CYAN from the$BLUE ChangeLog.txt$CYAN in local folder$NC"
            echo -en "$CYAN\nWant view the diff between these files?$NC\n(y)es - (n)o $GREEN(press enter to yes):$NC "
            read diffChangLog

            if [ "$diffChangLog" != 'n' ]; then
                echo
                diff -u ChangeLog.txt $versionDownload/ChangeLog.txt
            fi
            rm ChangeLog.txt
        fi

        if [ "$contineOrJump" == 'y' ]; then
            tmpMd5sumBeforeDownload=`mktemp`

            listOfFilesBeforeDownload=`find $versionDownload/ -type f -print`

            echo -en "$CYAN\nCreating a$BLUE md5sum$RED (before the download)$CYAN from files found (in the folder $GREEN$versionDownload/$CYAN)$NC. Please wait..."
            for file in $listOfFilesBeforeDownload; do
                md5sum $file >> $tmpMd5sumBeforeDownload
            done
            echo -e "$CYAN\n\nThe$BLUE md5sum$RED (before the download)$CYAN was saved in the tmp file: $GREEN$tmpMd5sumBeforeDownload$NC"
        fi
    else
        contineOrJump="y"
    fi

    if [ "$contineOrJump" == 'y' ]; then
        echo -en "$CYAN\nDownloading files$NC. Please wait...\n\n"

        if [ "$downloadSource" == 'y' ]; then
            lftp -c 'open '$mirrorSource'; mirror -c -e '$versionDownload'/'
            # -c continue a mirror job if possible
            # -e delete files not present at remote site
        else
            lftp -c 'open '$mirrorSource'; mirror -c -e --exclude source/ --exclude patches/source/ '$versionDownload'/'
        fi
    fi

    if [ "$tmpMd5sumBeforeDownload" != '' ]; then
        tmpMd5sumAfterDownload=`mktemp`

        listOfFilesAfterDownload=`find $versionDownload/ -type f -print`

        echo -en "$CYAN\nCreating a$BLUE md5sum$RED (after the download)$CYAN from files (in the folder $GREEN$versionDownload/$CYAN)$NC. Please wait..."
        for file in $listOfFilesAfterDownload; do
            md5sum $file >> $tmpMd5sumAfterDownload
        done
        echo -e "$CYAN\n\nThe$BLUE md5sum$RED (after the download)$CYAN was saved in the tmp file: $GREEN$tmpMd5sumAfterDownload$NC"

        echo -en "$CYAN\nChecking the changes in the files$BLUE before$CYAN with$BLUE after$CYAN download$NC. Please wait..."
        changeResult=`diff -w $tmpMd5sumBeforeDownload $tmpMd5sumAfterDownload`

        if [ "$changeResult" == '' ]; then
            echo -e "$CYAN\nNone changes made in the local folder -$GREEN All file still the same after de download$NC\n"
        else
            echo -e "$RED\n\nChanges made in local files...$NC"

            diffBeforeDownload=`diff -u $tmpMd5sumBeforeDownload $tmpMd5sumAfterDownload | grep -v "^--" | grep "^-" | awk '{print $2}'`
            diffAfterDownload=`diff -u $tmpMd5sumBeforeDownload $tmpMd5sumAfterDownload | grep -v "^++" | grep "^+" | awk '{print $2}'`

            for lineA in `echo $diffBeforeDownload`; do
                for lineB in `echo $diffAfterDownload`; do
                    if [ "$lineA" == "$lineB" ]; then
                        filesUpdate+=$lineA\|
                    fi
                done
            done

            if [ "$filesUpdate" != '' ]; then
                echo -e "$GREEN\nFile(s) updated:$NC"
                echo "$filesUpdate" | sed 's/|/\n/g' | sort
            fi

            for lineA in `echo $diffBeforeDownload`; do
                diffLineDeleted=`echo $diffAfterDownload | grep $lineA`
                if [ "$diffLineDeleted" == '' ]; then
                    filesDeleted+=$lineA\|
                fi
            done

            if [ "$filesDeleted" != '' ]; then
                echo -e "$RED\nFile(s) deleted:$NC"
                echo "$filesDeleted" | sed 's/|/\n/g' | sort
            fi

            for lineB in `echo $diffAfterDownload`; do
                diffLineNewFiles=`echo $diffBeforeDownload | grep $lineB`
                if [ "$diffLineNewFiles" == '' ]; then
                    filesNew+=$lineB\|
                fi
            done

            if [ "$filesNew" != '' ]; then
                echo -e "$BLUE\nNew file(s) downloaded:$NC"
                echo "$filesNew" | sed 's/|/\n/g' | sort
            fi
        fi

        rm $tmpMd5sumBeforeDownload $tmpMd5sumAfterDownload
    fi

    cd $versionDownload/

    echo -en "$CYAN\nWant check the integrity of downloaded files with the server?$NC\n(y)es - (n)o $GREEN(press enter to yes):$NC "
    read checkFiles

    if [ "$checkFiles" == 'y' ] || [ "$checkFiles" == '' ]; then
        echo -en "$CYAN\nChecking the integrity of the files$NC. Please wait..."
        if [ "$downloadSource" == 'y' ]; then
            checkFilesResult=`tail +13 CHECKSUMS.md5 | md5sum -c --quiet`
        else
            checkFilesResult=`tail +13 CHECKSUMS.md5 | grep -v "source/" | grep -v "patches/source/" | md5sum -c --quiet`
        fi

        echo -en "$CYAN\n\nFiles integrity:"
        if [ "$checkFilesResult" == '' ]; then
            echo -e "$GREEN Good $BLUE- Files are equal to the server$NC"
        else
            echo -e "$RED Bad $BLUE- Files different to the server$NC"
            echo -e "$RED$checkFilesResult$NC"
        fi
    fi

    cd ..

    echo -en "$CYAN\nWant create a ISO file from downloaded folder?$NC\n(y)es - (n)o $GREEN(press enter to no):$NC "
    read generateISO

    if [ "$generateISO" == 'y' ]; then
        datePartName=`date +%Hh-%Mmin-%dday-%mmouth-%Yyear`
        isoFileName=$versionDownload\_date-$datePartName

        olderIsoSlackware=`ls | grep "slackware.*iso"`

        if [ "$olderIsoSlackware" != '' ]; then
            echo -e "$CYAN\nOlder ISO file slackware found:$GREEN $olderIsoSlackware$NC"
            echo -en "$CYAN\nDelete the older ISO file(s) before continue?$NC\n(y)es - (n)o $GREEN(press enter to no):$NC "
            read deleteOlderIso

            if [ "$deleteOlderIso" == 'y' ]; then
                rm slackware*.iso
            fi
        fi

        echo -en "$CYAN\nCreating ISO file.$NC Please wait..."
        mkisofs -pad -r -J -quiet -o "$isoFileName".iso "$versionDownload"/
        # -pad   Pad output to a multiple of 32k (default)
        # -r     Generate rationalized Rock Ridge directory information
        # -J     Generate Joliet directory information
        # -quiet Run quietly
        # -o     Set output file name

        echo -e "$CYAN\n\nThe ISO file $GREEN\"$isoFileName.iso\"$CYAN was generated by the folder $GREEN\"$versionDownload\"/$NC\n"
    else
        echo -e "$CYAN\nExiting...$GREEN\n\nIf you want create a ISO file, use:$BLUE\nmkisofs -pad -r -J -o \"isoFileName\".iso \"$versionDownload\"$NC\n"
    fi
fi
