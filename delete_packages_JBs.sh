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
# Script: Delete package from a local directory that you don't want
#
# Last update: 28/03/2017
#
# Tip: Add the packages you want in the packagesList
# Need one space before add more
#
echo -e "\nThis script \"delete\"/\"move\" packages from a Clone folder\n"

folderWork=$1
if [ "$folderWork" == '' ]; then
    echo -e "\nError: You need pass the folder to work\n"
elif [ ! -d "$folderWork" ]; then
    echo -e "\nError: The dictory \"$folderWork\" not exist\n"
else
    folderWork=`echo $folderWork | sed "s/\///g"` # Remove the / in the end
    cd $folderWork

    folderDeletedFiles="../toBeDeleted"`date +%s`
    mkdir $folderDeletedFiles 2> /dev/null

    ## Add packages that you want in the packagesList
    ## Need one space before add more
    ## For example: Remove ktorrent
    # packagesList=$packagesList" ktorrent libktorrent"

    # Remover games
    packagesList="palapeli bomber granatier
    kblocks ksnakeduel kbounce kbreakout kgoldrunner
    kspaceduel kapman kolf kollision kpat lskat blinken
    khangman pairs ktuberling kdiamond ksudoku kubrick
    picmi bovo kblackbox kfourinline kmahjongg kreversi
    ksquares kigo kiriki kshisen gnuchess katomic
    kjumpingcube kmines knetwalk killbots klickety
    klines konquest ksirk knavalbattle kanagram amor kajongg"

    # Remove XFCE or/and KDE
	echo -en "\nLeave XFCE or KDE?\n(1) Leave XFCE, (2) Leave KDE, (3) Remove XFCE and KDE (hit enter to remove KDE): "
    read leaveXGUI
    if [ "$leaveXGUI" == '1' ] || [ "$leaveXGUI" == '' ]; then
        packagesList=$packagesList" kde" # Also remove kdei
    elif [ "$leaveXGUI" == '2' ]; then
        packagesList=$packagesList" xfce"
    else
        packagesList=$packagesList" kde xfce" # Also remove kdei
    fi

    # Remover servidor X - Leave fluxbox # Safe propose
    packagesList=$packagesList" twm blackbox windowmaker fvwm"

    # Remover kopote
    packagesList=$packagesList" kdenetwork-filesharing kdenetwork-strigi-analyzers kopete"

    # Remove nepomuk
    packagesList=$packagesList" nepomuk-core nepomuk-widgets"

    # Remove akonadi
    packagesList=$packagesList" akonadi"

    echo -e "\n\nRemove \"gnome packages\"?\"gcr- polkit-gnome gnome-themes libgnome-keyring gnome-keyring\""
    echo -en "Recommended if you remove XFCE, but leave if you not remove XFCE\n(y)es remove - (n)ot remove: "
    read removeGnomePackages
    if [ "$removeGnomePackages" == 'y' ]; then
        # Remove gnome "packages" # gcr- to not remove libgcrypt
        packagesList=$packagesList" gcr- polkit-gnome gnome-themes libgnome-keyring gnome-keyring"
    else
        echo -e "\nNot removing \"gnome packages\"\n"
    fi

    # Remove other packages
    packagesList=$packagesList" seamonkey pidgin xchat dragon thunderbird kplayer
    calligra bluedevil blueman bluez-firmware bluez xine-lib xine-ui
    emacs amarok audacious
    vim-gvim vim sendmail-cf sendmail xpdf tetex-doc tetex kget"

    ## Virtualbox need # Remover kernel-source
    #packagesList=$packagesList" kernel-source"

    filesDeleted="../0_filesDeleted.txt"
    filesNotFound="../0_filesNotFound.txt"

    for packageName in $packagesList; do
        echo -e "\nLooking for \"$packageName\""
        resultFind=`find . | grep $packageName`

        if [ "$resultFind" == '' ]; then
            echo "Not found: \"$packageName\"" | tee -a $filesNotFound
        else
            echo -e "Files removed: \"$packageName\"\n$resultFind\n" | tee -a $filesDeleted
            mv $resultFind $folderDeletedFiles
        fi
    done

    echo -e "\nFiles \"toBeDeleted\" are moved to \"$folderDeletedFiles\""

    echo -en "\nWant create a ISO file from work folder?\n(y)es - (n)o (press enter to no): "
    read generateISO

    isoFileName=$folderWork"_SelectedPkgss_date_"`date +%H_%M_%d_%m_%Y`

    if [ "$generateISO" == 'y' ]; then
        cd ../

        echo -en "\nCreating ISO file. Please wait..."
        mkisofs -pad -r -J -quiet -o "$isoFileName".iso "$folderWork"
        # -pad   Pad output to a multiple of 32k (default)
        # -r     Generate rationalized Rock Ridge directory information
        # -J     Generate Joliet directory information
        # -quiet Run quietly
        # -o     Set output file name

        echo -e "\n\nThe ISO file \"$isoFileName.iso\" was generated by the folder \"$folderWork\"/\n"
    else
        echo -e "\n\nExiting...\n\nIf you want create a ISO file, use:\nmkisofs -pad -r -J -o \"$isoFileName\".iso \"$folderWork\"/\n"
    fi
fi
