set -x
set -e

export LC_ALL=C


source /common.sh
install_cleanup_trap

if [ "$WORKER" == "1" ]; then

    ######################################################################
    # Optimize power consumption of Rpi - mostly turn off peripherals
    ######################################################################

    # assign minimal memory to GPU
    echo "gpu_mem=16"            | sudo tee /boot/config.txt -a

    # disable bluetooth, audio, camera and display autodetects
    sudo systemctl disable hciuart
    echo "dtoverlay=disable-bt" | sudo tee -a /boot/config.txt
    echo "dtparam=audio=off"    | sudo tee -a /boot/config.txt
    echo "camera_auto_detect=0" | sudo tee -a /boot/config.txt
    echo "display_auto_detect=0" | sudo tee -a /boot/config.txt

    # disable USB. This fails for the RPi Zero and A models, hence the starting "-"" to ignore error
    # TODO: -echo '1-1' |sudo tee /sys/bus/usb/drivers/usb/unbind

    # disable HDMI
    echo "hdmi_blanking=2" | sudo tee -a /boot/config.txt

    # remove activelow LED
    # TODO this doesn't work for RPi Zero, https://mlagerberg.gitbooks.io/raspberry-pi/content/5.2-leds.html
    echo "dtparam=act_led_trigger=none" | sudo tee -a /boot/config.txt
    echo "dtparam=act_led_activelow=off" | sudo tee -a /boot/config.txt

    #####################################################################
    #####################################################################

    # add hardware pwm
    echo "dtoverlay=pwm-2chan,pin=12,func=4,pin2=13,func2=4" | sudo tee -a /boot/config.txt
fi

# the below will remove swap, which should help extend the life of SD cards:
# https://raspberrypi.stackexchange.com/questions/169/how-can-i-extend-the-life-of-my-sd-card
sudo apt-get remove dphys-swapfile -y

# put /tmp into memory, as we write to it a lot.
echo "tmpfs /tmp tmpfs defaults,noatime 0 0" | sudo tee -a /etc/fstab

