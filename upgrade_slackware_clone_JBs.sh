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
# Script: Upgrade the slackware form a local clone mirror
#
# Last update: 14/06/2017
#
echo -e "\n\n\n\t### Script in beta-tests - take care before use! ###\n\n"
#
folderWork=$1

if [ "$folderWork" == '' ]; then
    echo -e "\nError: You need pass the folder to work\n"
elif [ ! -d "$folderWork" ]; then
    echo -e "\nError: The directory \"$folderWork\" not exist\n"
else
    enterContinue () {
        echo -n "Press enter to continue..."
        read
        echo
    }

    workFolder=$1
    echo "Folder work: $workFolder"
    enterContinue

    cd $workFolder || exit

    echo -n "Slackware - "
    if  echo $workFolder | grep -q "current"; then
        echo "current:"
        slackwarePackageFolder=$(ls | grep "slackware")
    else
        echo "stable:"
        slackwarePackageFolder="patches/packages/"
    fi

    echo -e  "Update folder: $workFolder/$slackwarePackageFolder"
    enterContinue

    cd $slackwarePackageFolder || exit
    echo "Change directory: cd $(pwd)"
    enterContinue

    upgradePKG () {
        pkgToUpgrade=$1

        echo "$pkgToUpgrade"
        read
        logFile="../../upgradePKGLog.r"

        for pkg in $pkgToUpgrade; do
            echo -e "Upgrade: $pkg"
            upgradepkg $pkg

            if [ "$?" == '0' ]; then
                echo -e "Upgrade: $pkg" >> $logFile
            fi
        done

        enterContinue
    }

    echo "Packages to upgrade (without kernel):"
    pkgWihtoutKernel=$(find . | grep -v "kernel" | grep "t.z$" | sort)
    upgradePKG "$pkgWihtoutKernel"

    echo "Packages (Kernel) to upgrade:"
    kernelToUpgrade=$(find . | grep "kernel" | grep "t.z$" | sort)

    upgradePKG "$kernelToUpgrade"

    echo "IMPORTANT!  *Before* attempting to reboot your system, you will need
    to make sure that the bootloader has been updated for the new kernel!
    First, be sure your initrd is up to date (if you use one).  You can
    build a new initrd automatically by running the
    mkinitrd_command_generator.sh script.

    If you're running the 64-bit kernel, or the 32-bit single processor
    kernel, this is the command to use:

    /usr/share/mkinitrd/mkinitrd_command_generator.sh -k 4.4.14 | bash

    If you're using the 32-bit SMP kernel, use this command:

    /usr/share/mkinitrd/mkinitrd_command_generator.sh -k 4.4.14-smp | bash

    If you use LILO, make sure the paths in /etc/lilo.conf point to a valid
    kernel and then type 'lilo' to reinstall LILO.  If you use a USB memory
    stick to boot, copy the new kernel to it in place of the old one."
    enterContinue

    echo "Also install the new package add (# slackpkg install-new). Look in file CHANGES_AND_HINTS.TXT"
    enterContinue
fi
echo "End of the script"
