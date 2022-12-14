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
# Last update: 14/12/2022
#
# Tip: Add the packages you want in the $packagesList
# Obs.: Need one space before add more
#
echo -e "\\nCreate a ISO file from a clone folder of Slackware\\n"

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
        echo -e "\\n # Using \$packagesList #"

        ## Add packages that you want in the packagesList
        ## Need one space before add more
        ## For example: Remove ktorrent
        # packagesList="$packagesList ktorrent libktorrent"

        # Remove games
        packagesList="palapeli bomber granatier kblocks ksnakeduel kbounce kbreakout kgoldrunner
        kspaceduel kapman kolf kollision kpat lskat blinken khangman pairs ktuberling katomic
        kjumpingcube kmines knetwalk kdiamond ksudoku kubrick picmi bovo kblackbox kfourinline
        kmahjongg kreversi ksquares kigo kiriki kshisen killbots klickety klines konquest ksirk
        knavalbattle kanagram amor kajongg xsnow libgtop"

        packagesList="$packagesList /patches/ /source/ testing/ extra/"

        # Remove knights gnuchess
        packagesList="$packagesList knights gnuchess"

        # Remove plasma-vault
        packagesList="$packagesList plasma-vault"

        # Remove XFCE or/and KDE
        echo -en "\\nLeave XFCE or KDE?\\n(1) Leave KDE, (2) Leave XFCE, (3) Remove XFCE and KDE (hit enter to Leave KDE): "
        read -r leaveXGUI
        if [ "$leaveXGUI" == '1' ] || [ "$leaveXGUI" == '' ]; then
            packagesListTmp="xfce"
        elif [ "$leaveXGUI" == '2' ]; then
            packagesListTmp="kde" # Also remove kde-l10n-
        elif [ "$leaveXGUI" == '3' ]; then
            packagesListTmp="kde xfce" # Also remove kde-l10n-
        fi

        echo -e "\\nWill remove \"$packagesListTmp\""
        packagesList="$packagesList $packagesListTmp"

        # Remove servidor X - Leave fluxbox # Safe propose
        packagesList="$packagesList twm blackbox windowmaker fvwm motif"

        # Remove kopote
        packagesList="$packagesList kdenetwork-filesharing kdenetwork-strigi-analyzers kopete"

        # Remove nepomuk
        packagesList="$packagesList nepomuk-core nepomuk-widgets"

        # Remove akonadi* akonadiconsole kalarm
        packagesList="$packagesList akonadi akonadi-calendar akonadi-calendar-tools akonadi-contacts
        akonadi-notes akonadi-import-wizard akonadi-mime akonadi-search akonadiconsole kalarm"

        # Remove digikam need akonadi-contacts
        packagesList="$packagesList digikam"

        # Remove kde-l10n- - others languages for the KDE
        packagesList="$packagesList kde-l10n-"

        # Remove some added to XFCE
        packagesList="$packagesList elementary-xfce gnome-themes-extra xfce4-panel-profiles
        xfce4-screensaver xfce4-whiskermenu-plugin thunar mousepad Greybird"

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
        calligra xine-lib xine-ui emacs amarok audacious sendmail-cf sendmail xpdf kget"

        # Dolphin need baloo baloo-widgets
        #packagesList="$packagesList baloo-widgets"

        # xxd (to see file as binary - xxd -b file - is in vim
        packagesList="$packagesList vim-gvim vim"

        # KDE5 (ktown AlienBob) - AC Power need the bluez-qt
        #packagesList="$packagesList bluez-qt"

        # Remove tetex (Slackware 14.2) / texlive (Slackware 15.0 and Current)
        packagesList="$packagesList tetex-doc tetex texlive"

        # Remove Bluetooth
        #packagesList="$packagesList bluedevil blueman bluez-firmware bluez"

        # Remove kleopatra
        packagesList="$packagesList kleopatra"

        # Virtualbox need # Remove kernel-source
        #packagesList="$packagesList kernel-source"

        countI='0'
        echo -e "\\nPackages that will be removed:\\n"
        for packageName in $packagesList; do
            echo -n "$packageName "
            if [ "$countI" == "5" ]; then
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

    dateISO=$(date +%d_%b_%Y)
    localISO=$(pwd | rev| cut -d '/' -f2- | rev)

    isoFileName="${folderWork}_AllPkgs_date_$dateISO"
    commandGenISOPart0="mkisofs -o \"../${isoFileName}.iso\" "
    commandGenISOPart2=""

    commandGenISOPart1="-R -J -V \"Slackware-current DVD\" \
-hide-rr-moved -hide-joliet-trans-tbl \
-v -d -N -no-emul-boot -boot-load-size 4 -boot-info-table \
-sort isolinux/iso.sort \
-b isolinux/isolinux.bin \
-c isolinux/isolinux.boot \
-preparer \"Slackware-current build for x86_64 by ryuuzaki42 <github.com/ryuuzaki42/12_clone_Slackware_repo_rsync>\" \
-publisher \"The Slackware Linux Project - http://www.slackware.com/\" \
-A \"Slackware-current DVD - build $dateISO\" "

    commandGenISOPart3="-eltorito-alt-boot -no-emul-boot -eltorito-platform 0xEF -eltorito-boot isolinux/efiboot.img \
."

    echo -en "\\nWant create a ISO file from work folder?\\n(y)es - (n)o (press enter to no): "
    read -r generateISO
    if [ "$generateISO" == 'y' ]; then
        echo -e "\\nCreating ISO file. Please wait..."
        if [ "$usePackagesList" == '2' ]; then
            appendMessage="Using packagesList (without some packages)"
            isoFileName="${folderWork}_SelectedPkgs_date_$dateISO"
            commandGenISOPart0="mkisofs -o \"../${isoFileName}.iso\" "
            commandGenISOPart2="-exclude-list \"$mkisofsExcludeList\" "
        fi

        commandGenISO=$commandGenISOPart0$commandGenISOPart1$commandGenISOPart2$commandGenISOPart3
        echo -e "\\nRunning:\\n$commandGenISO\\n"
        eval "$commandGenISO"

        echo -en "\\nCreating md5sum from ../$isoFileName. Please wait..."
        md5sum "../${isoFileName}.iso" > "../${isoFileName}.iso.md5"

        echo -e "\\n\\nThe ISO file: $localISO/$isoFileName.iso\\nWas generated by the folder $appendMessage: $localISO/$folderWork/\\n"

        if [ "$usePackagesList" == '2' ]; then
            echo -e "Take a look in the files:\\n"
            echo "$(pwd)/"
            echo -e "\\t\\t $(find "$mkisofsExcludeList" | rev | cut -d '/' -f1 | rev)"
            echo -e "\\t\\t $(find "$filesIgnoredInTheISO" | rev | cut -d '/' -f1 | rev)"
            echo -e "\\t\\t $(find "$filesNotFound" 2> /dev/null | rev | cut -d '/' -f1 | rev)"
        fi
    else
        commandGenISO=$commandGenISOPart0$commandGenISOPart1$commandGenISOPart3
        echo -e "\\n\\nExiting...\\n\\nIf you want create a ISO file, use:\\n\\ncd $localISO/\\n\\n$commandGenISO\\n"
    fi
fi
