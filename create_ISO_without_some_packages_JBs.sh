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
# Script: Create a ISO without some package from a local directory that you don't want
#
# Last update: 28/03/2021
#
# Tip: Add the packages you want in the packagesList
# Need one space before add more
#
echo -e "\\nThis script create a ISO file from a clone folder of Slackware\\n"

folderWork=$1
if [ "$folderWork" == '' ]; then
    echo -e "Error: You need pass the folder to work\\n"
elif [ ! -d "$folderWork" ]; then
    echo -e "Error: The directory \"$folderWork\" not exist\\n"
else
    folderWork=${folderWork//\//} # Remove the / in the end
    cd "$folderWork" || exit

    echo -en "ISO with all packages or remove the packages in packagesList?\\n1 to all package - 2 to use packagesList (hit enter to use packagesList): "
    read -r usePackagesList

    if [ "$usePackagesList" == '' ] || [ "$usePackagesList" == '2' ]; then
        usePackagesList=2
        echo -e "\\nUsing packagesList"

        ## Add packages that you want in the packagesList
        ## Need one space before add more
        ## For example: Remove ktorrent
        # packagesList="$packagesList ktorrent libktorrent"

        # Remove games
        packagesList="palapeli bomber granatier
        kblocks ksnakeduel kbounce kbreakout kgoldrunner
        kspaceduel kapman kolf kollision kpat lskat blinken
        khangman pairs ktuberling kdiamond ksudoku kubrick
        picmi bovo kblackbox kfourinline kmahjongg kreversi
        ksquares kigo kiriki kshisen gnuchess katomic
        kjumpingcube kmines knetwalk killbots klickety xsnow
        klines konquest ksirk knavalbattle kanagram amor kajongg"

        # Remove XFCE or/and KDE
        echo -en "\\nLeave XFCE or KDE?\\n(1) Leave KDE, (2) Leave XFCE, (3) Remove XFCE and KDE (hit enter to Leave KDE): "
        read -r leaveXGUI
        if [ "$leaveXGUI" == '1' ] || [ "$leaveXGUI" == '' ]; then
            packagesListTmp=" xfce"
        elif [ "$leaveXGUI" == '2' ]; then
            packagesListTmp=" kde" # Also remove kde-l10n-
        elif [ "$leaveXGUI" == '3' ]; then
            packagesListTmp=" kde xfce" # Also remove kde-l10n-
        fi

        echo -e "\\nWill remove \"$packagesListTmp\""
        packagesList="$packagesList $packagesListTmp"

        # Remove servidor X - Leave fluxbox # Safe propose
        packagesList="$packagesList twm blackbox windowmaker fvwm motif"

        # Remove kopote
        packagesList="$packagesList kdenetwork-filesharing kdenetwork-strigi-analyzers kopete"

        # Remove nepomuk
        packagesList="$packagesList nepomuk-core nepomuk-widgets"

        # Remove akonadi
        packagesList="$packagesList akonadi"

        # Remove kde-l10n- - others languages for the KDE
        packagesList="$packagesList kde-l10n-"

        echo -e "\\nRemove \"gnome packages\"? \"gcr- polkit-gnome gnome-themes libgnome-keyring gnome-keyring\""
        echo "Recommended if you remove XFCE, but leave if you not remove XFCE."
        echo -n "(y)es to remove or (n)ot remove (hit enter to remove): "
        read -r removeGnomePackages
        if [ "$removeGnomePackages" == 'y' ] || [ "$removeGnomePackages" == '' ]; then
            # Remove gnome "packages" # gcr- to not remove libgcrypt
            packagesList="$packagesList gcr- polkit-gnome gnome-themes libgnome-keyring gnome-keyring"
            echo -en "\\nR"
        else
            echo -en "\\nNot r"
        fi
        echo -e "emoving \"gnome packages\"\\n"

        # Remove other packages
        packagesList="$packagesList seamonkey pidgin xchat dragon thunderbird kplayer
        calligra xine-lib xine-ui emacs amarok audacious vim-gvim vim sendmail-cf sendmail xpdf kget"

        # Remove textex / textlive
        packagesList="$packagesList tetex-doc tetex texlive"

        # Remove Bluetooth
        #packagesList="$packagesList bluedevil blueman bluez-firmware bluez"

        # Virtualbox need # Remove kernel-source
        #packagesList="$packagesList kernel-source"

        countI='0'
        echo -e "\\nPackages that will be removed:\\n"
        for packageName in $packagesList; do
            echo -n "$packageName "
            if [ "$countI" == "10" ]; then
                echo
                countI='0'
            else
                ((countI++))
            fi
        done

        echo -en "\\n\\nWant continue? (y)es or (n)o: "
        read -r continueOrNot
        if [ "$continueOrNot" != 'y' ]; then
            echo -e "\\nJust exiting by local choice\\n"
            exit 0
        fi

        filesIgnoredInTheISO="../0_filesIgnoredInTheISO.txt"
        mkisofsExcludeList="../1_mkisofsExcludeList.txt"
        filesNotFound="../2_filesNotFound.txt"

        rm "$filesIgnoredInTheISO" "$mkisofsExcludeList" "$filesNotFound" 2> /dev/null

        for packageName in $packagesList; do
            echo -e "\\nLooking for \"$packageName\""
            resultFind=$(find . | grep "$packageName" | grep -E ".t.z$|.asc$|.txt$")

            if [ "$resultFind" == '' ]; then
                echo "Not found: \"$packageName\"" | tee -a "$filesNotFound"
            else
                echo -e "Files ignored with the pattern: \"$packageName\"\\n$resultFind\\n" | tee -a "$filesIgnoredInTheISO"
                echo "$resultFind" | rev | cut -d '/' -f1 | rev >> "$mkisofsExcludeList"
            fi
        done
    else
        echo -e "\\nUsing all packages"
    fi

    isoFileName="${folderWork}_AllPackages_date_$(date +%d_%m_%Y)"
    dateISO=$(date +%d_%b_%Y)
    localISO=$(pwd | rev| cut -d '/' -f2- | rev)
    commandGenISOPart2=""

    echo -en "\\nWant create a ISO file from work folder?\\n(y)es - (n)o (press enter to no): "
    read -r generateISO
    if [ "$generateISO" == 'y' ]; then
        echo -e "\\nCreating ISO file. Please wait..."
        if [ "$usePackagesList" == '2' ]; then
            appendMessage="Using packagesList (without some packages)"
            isoFileName="${folderWork}_SelectedPkgs_date_$(date +%d_%m_%Y)"
            commandGenISOPart2="-exclude-list "$mkisofsExcludeList" \
"
        fi

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

        commandGenISO=$commandGenISOPart1$commandGenISOPart2$commandGenISOPart3
        echo -e "\\nRunning:\\n$commandGenISO\\n"
        eval $commandGenISO

        echo -e "\\nThe ISO file: $localISO/$isoFileName.iso\\nWas generated by the folder $appendMessage: $localISO/$folderWork/\\n"

        if [ "$usePackagesList" == '2' ]; then
            echo -e "\\nTake a look in the files:\\n"
            echo "$(pwd)/"
            echo -e "\\t\\t $(find $mkisofsExcludeList | rev | cut -d '/' -f1 | rev)"
            echo -e "\\t\\t $(find $filesIgnoredInTheISO | rev | cut -d '/' -f1 | rev)"
            echo -e "\\t\\t $(find $filesNotFound 2> /dev/null | rev | cut -d '/' -f1 | rev)"
        fi
    else
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
        echo -e "\\n\\nExiting...\\n\\nIf you want create a ISO file, use:\\n\\ncd $localISO/\\n\\n$commandGenISO\\n"
    fi
fi
