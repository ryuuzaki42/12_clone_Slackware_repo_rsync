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
# Last update: 01/11/2016
#
# Tip: Use the file insed one "old" ISO to make less things to download

mirrorSource="ftp://ftp.osuosl.org/.2/slackware/"

echo -e "\nDefault mirror: $mirrorSource\n"

echo -en "\nWant change de default mirror?\n(y)es - (n)o (enter to no): "
read changeMirror

if [ "$changeMirror" == 'y' ]; then
    mirrorSource=''

    while echo "$mirrorSource" | grep -v -q -E "ftp|http"; do
        echo -en "\nInsert the new mirror: "
        read mirrorSource
    done

    echo -e "\nNew mirror: $mirrorSource\n"
fi

echo -en "\nWith version Slackware you want? (enter to 14.2): "
read versioSlackware

if [ "$versioSlackware" == '' ]; then
    versioSlackware="14.2"
fi

echo -en "\nWith arch you want? \n(1) - 32 bits or (2) to 64 bits (enter to 64 bits): "
read choosedArch

if [ "$choosedArch" == '1' ]; then
    choosedArch=''
else
    choosedArch="64"
fi

versionDownload=slackware$choosedArch-$versioSlackware

echo -en "\nWant download the source code?\n(y)es - (n)o (enter to no): "
read downloadSource

echo -en "\nWill download (by lftp) \"$versionDownload\" "
if [ "$downloadSource" == 'y' ]; then
    echo -n "with"
else
    echo -n "without"
fi
echo -e " the source code from \"$mirrorSource\""

echo -en "\n\tWant continue?\n\t(y)es - (n)o: "
read contineLftp

if [ $contineLftp == 'n' ]; then
    echo -e "\nJust exiting by user choice\n"
else
    echo -e "\n\nPlease wait until download ends...\n"

    if [ "$downloadSource" == 'y' ]; then
        lftp -c 'open '$mirrorSource'; mirror -c -e '$versionDownload'/'
        # -c continue a mirror job if possible
        # -e delete files not present at remote site
    else
        lftp -c 'open '$mirrorSource'; mirror -c -e --exclude source/ --exclude patches/source/ '$versionDownload'/'
    fi

    cd $versionDownload

    echo -e "\n\nChecking the integrity of the files...\n"
    if [ "$downloadSource" == 'y' ]; then
        tail +13 CHECKSUMS.md5 | md5sum -c --quiet
    else
        tail +13 CHECKSUMS.md5 | grep -v "source/" | grep -v "patches/source/" | md5sum -c --quiet
    fi

    cd ..
fi
